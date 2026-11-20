//
//  CachingPoemSearcherTests.swift
//  ChakameTests
//

@testable import Chakame
import Foundation
import Testing

struct CachingPoemSearcherTests {
    private let page = [PoemSearchResult(id: 1, title: "غزل ۱")]

    @Test func repeatedSearchComesFromMemory() async throws {
        let base = RecordingPoemSearcher(pages: [1: page])
        let searcher = CachingPoemSearcher(base: base, minimumInterval: .zero)

        _ = try await searcher.search(term: "عشق", poetId: 2, catId: 0, page: 1, pageSize: 10)
        let again = try await searcher.search(term: "عشق", poetId: 2, catId: 0, page: 1, pageSize: 10)

        #expect(again.map(\.id) == [1])
        #expect(await base.calls.count == 1)
    }

    @Test func differentPoetOrPageIsFetched() async throws {
        let base = RecordingPoemSearcher(pages: [1: page])
        let searcher = CachingPoemSearcher(base: base, minimumInterval: .zero)

        _ = try await searcher.search(term: "عشق", poetId: 2, catId: 0, page: 1, pageSize: 10)
        _ = try await searcher.search(term: "عشق", poetId: 3, catId: 0, page: 1, pageSize: 10)
        _ = try await searcher.search(term: "عشق", poetId: 2, catId: 0, page: 2, pageSize: 10)

        #expect(await base.calls.count == 3)
    }

    @Test func failuresAreNotCached() async throws {
        let base = RecordingPoemSearcher(pages: [1: page], failing: true)
        let searcher = CachingPoemSearcher(base: base, minimumInterval: .zero)

        await #expect(throws: NetworkError.self) {
            try await searcher.search(term: "عشق", poetId: 2, catId: 0, page: 1, pageSize: 10)
        }
        await base.setFailing(false)
        let results = try await searcher.search(term: "عشق", poetId: 2, catId: 0, page: 1, pageSize: 10)

        #expect(results.count == 1)
        #expect(await base.calls.count == 2)
    }

    @Test func requestsAreSpacedOut() async throws {
        let base = RecordingPoemSearcher(pages: [1: page])
        let searcher = CachingPoemSearcher(base: base, minimumInterval: .milliseconds(200))
        let clock = ContinuousClock()

        let start = clock.now
        _ = try await searcher.search(term: "عشق", poetId: 2, catId: 0, page: 1, pageSize: 10)
        _ = try await searcher.search(term: "باده", poetId: 2, catId: 0, page: 1, pageSize: 10)
        _ = try await searcher.search(term: "می", poetId: 2, catId: 0, page: 1, pageSize: 10)

        #expect(clock.now - start >= .milliseconds(400))
        #expect(await base.calls.count == 3)
    }

    @Test func oldestPageIsDroppedWhenFull() async throws {
        let base = RecordingPoemSearcher(pages: [1: page])
        let searcher = CachingPoemSearcher(base: base, minimumInterval: .zero, capacity: 1)

        _ = try await searcher.search(term: "عشق", poetId: 2, catId: 0, page: 1, pageSize: 10)
        _ = try await searcher.search(term: "باده", poetId: 2, catId: 0, page: 1, pageSize: 10)
        _ = try await searcher.search(term: "عشق", poetId: 2, catId: 0, page: 1, pageSize: 10)

        #expect(await base.calls.count == 3)
    }
}
