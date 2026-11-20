//
//  PoemSearchViewModelTests.swift
//  ChakameTests
//

@testable import Chakame
import Foundation
import SwiftData
import Testing

@MainActor
@Suite(.serialized)
struct PoemSearchViewModelTests {
    // Keep the container alive: a context whose container is deallocated crashes.
    let container: ModelContainer
    let context: ModelContext

    init() throws {
        container = try ModelContainerFactory.make(inMemory: true)
        context = container.mainContext
    }

    private func makeViewModel(
        _ searcher: RecordingPoemSearcher,
        poetId: Int = 2,
        catId: Int = 0
    ) -> PoemSearchViewModel {
        PoemSearchViewModel(
            poetId: poetId,
            catId: catId,
            searcher: searcher,
            store: PoemSearchStoreService(context: context)
        )
    }

    @Test func shortTermSendsNoRequest() async {
        let searcher = RecordingPoemSearcher(pages: [1: results(1 ... 3)])
        let viewModel = makeViewModel(searcher)

        await viewModel.search(term: " ع ")

        #expect(await searcher.calls.isEmpty)
        #expect(viewModel.phase == .tooShort)
        #expect(viewModel.poems.isEmpty)
    }

    @Test func resultsAreCachedInOrder() async throws {
        let searcher = RecordingPoemSearcher(pages: [1: results(1 ... 2)])
        let viewModel = makeViewModel(searcher)

        await viewModel.search(term: "عشق")

        #expect(viewModel.phase == .loaded)
        #expect(viewModel.poems.map(\.id) == [1, 2])
        #expect(viewModel.poems.map(\.excerpt) == ["بیت 1", "بیت 2"])
        #expect(!viewModel.canLoadMore)
        #expect(try context.fetchCount(FetchDescriptor<PoemEntity>()) == 2)
    }

    @Test func loadMoreAppendsPagesUntilAShortPage() async {
        let pageSize = PoemSearchViewModel.pageSize
        let searcher = RecordingPoemSearcher(pages: [
            1: results(1 ... pageSize),
            2: results((pageSize + 1) ... (pageSize + 3))
        ])
        let viewModel = makeViewModel(searcher)

        await viewModel.search(term: "عشق")
        #expect(viewModel.canLoadMore)

        await viewModel.loadMore()
        #expect(viewModel.poems.count == pageSize + 3)
        #expect(!viewModel.canLoadMore)

        await viewModel.loadMore()
        #expect(await searcher.calls.map(\.page) == [1, 2])
    }

    @Test func failedSearchCanBeRetried() async {
        let searcher = RecordingPoemSearcher(pages: [1: results(1 ... 2)], failing: true)
        let viewModel = makeViewModel(searcher)

        await viewModel.search(term: "عشق")
        #expect(viewModel.phase == .failed)

        await searcher.setFailing(false)
        await viewModel.retry()?.value
        #expect(viewModel.phase == .loaded)
        #expect(viewModel.poems.count == 2)
    }

    @Test func searchPassesPoetAndCategory() async {
        let searcher = RecordingPoemSearcher(pages: [:])
        let viewModel = makeViewModel(searcher, poetId: 2, catId: 24)

        await viewModel.search(term: "  عشق ")

        let call = await searcher.calls.first
        #expect(call?.term == "عشق")
        #expect(call?.poetId == 2)
        #expect(call?.catId == 24)
        #expect(viewModel.phase == .loaded)
        #expect(viewModel.poems.isEmpty)
    }

    @Test func submittingTheShowingTermAgainSendsNothing() async {
        let searcher = RecordingPoemSearcher(pages: [1: results(1 ... 2)])
        let viewModel = makeViewModel(searcher)

        await viewModel.submit(term: "عشق")?.value
        #expect(viewModel.submit(term: "عشق ") == nil)
        #expect(await searcher.calls.count == 1)

        await viewModel.submit(term: "عشق و")?.value
        #expect(await searcher.calls.count == 2)
    }

    @Test func pressingSearchTwiceWhileLoadingSendsOneRequest() async {
        let searcher = RecordingPoemSearcher(pages: [1: results(1 ... 2)], delay: .milliseconds(100))
        let viewModel = makeViewModel(searcher)

        let first = viewModel.submit(term: "عشق")
        #expect(viewModel.submit(term: "عشق") == nil)
        await first?.value

        #expect(await searcher.calls.count == 1)
        #expect(viewModel.phase == .loaded)
    }

    @Test func aNewTermReplacesTheRunningSearch() async {
        let searcher = RecordingPoemSearcher(pages: [1: results(1 ... 2)], delay: .milliseconds(100))
        let viewModel = makeViewModel(searcher)

        let first = viewModel.submit(term: "عشق")
        let second = viewModel.submit(term: "باده")
        await first?.value
        await second?.value

        #expect(viewModel.phase == .loaded)
        #expect(await searcher.calls.map(\.term).contains("باده"))
    }

    @Test func cancelClearsResults() async {
        let searcher = RecordingPoemSearcher(pages: [1: results(1 ... 2)])
        let viewModel = makeViewModel(searcher)

        await viewModel.submit(term: "عشق")?.value
        viewModel.cancel()

        #expect(viewModel.phase == .idle)
        #expect(viewModel.poems.isEmpty)
    }

    @Test func aFailedPageIsNotRetriedUntilAsked() async {
        let pageSize = PoemSearchViewModel.pageSize
        let searcher = RecordingPoemSearcher(pages: [1: results(1 ... pageSize)])
        let viewModel = makeViewModel(searcher)
        await viewModel.search(term: "عشق")

        await searcher.setFailing(true)
        await viewModel.loadMore()
        await viewModel.loadMore()
        #expect(viewModel.loadMoreFailed)
        #expect(await searcher.calls.count == 2)

        await searcher.setFailing(false)
        await viewModel.retry()?.value
        #expect(!viewModel.loadMoreFailed)
        #expect(await searcher.calls.count == 3)
    }

    private func results(_ ids: ClosedRange<Int>) -> [PoemSearchResult] {
        ids.map { id in
            PoemSearchResult(
                id: id,
                title: "غزل \(id)",
                plainText: "\nبیت \(id)\r\nمصراع دوم"
            )
        }
    }
}

/// Serves canned pages and records every request.
actor RecordingPoemSearcher: PoemSearcher {
    struct Call {
        let term: String
        let poetId: Int
        let catId: Int
        let page: Int
    }

    private let pages: [Int: [PoemSearchResult]]
    private var failing: Bool
    private let delay: Duration?
    private(set) var calls: [Call] = []

    init(pages: [Int: [PoemSearchResult]], failing: Bool = false, delay: Duration? = nil) {
        self.pages = pages
        self.failing = failing
        self.delay = delay
    }

    func setFailing(_ failing: Bool) {
        self.failing = failing
    }

    func search(term: String, poetId: Int, catId: Int, page: Int, pageSize: Int) async throws -> [PoemSearchResult] {
        calls.append(Call(term: term, poetId: poetId, catId: catId, page: page))
        if let delay {
            try await Task.sleep(for: delay)
        }
        if failing {
            throw NetworkError.invalidServerResponse
        }
        return pages[page] ?? []
    }
}
