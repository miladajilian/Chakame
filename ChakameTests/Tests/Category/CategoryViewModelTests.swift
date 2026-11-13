//
//  CategoryViewModelTests.swift
//  ChakameTests
//

@testable import Chakame
import Foundation
import SwiftData
import Testing

@MainActor
@Suite(.serialized)
struct CategoryViewModelTests {
    // Keep the container alive: a context whose container is deallocated crashes.
    let container: ModelContainer
    let context: ModelContext
    let fetcher = SlowCategoriesFetcher()
    let viewModel: CategoryViewModel

    init() throws {
        container = try ModelContainerFactory.make(inMemory: true)
        context = container.mainContext
        viewModel = CategoryViewModel(
            categoriesFetcher: fetcher,
            categoryStore: CategoryStoreService(context: context),
            poemViewModel: PoemViewModel(
                poemFetcher: PoemFetcherMock(),
                poemStore: PoemStoreService(context: context),
                verseStore: VerseStoreService(context: context)
            )
        )
    }

    @Test func fetchStoresChildrenAndStopsLoading() async throws {
        await viewModel.fetchCategories(parentCatId: 1)

        #expect(!viewModel.isLoading)
        #expect(try storedParentIds() == [1])
    }

    /// Switching poets on iPad rebuilds the category screen while the first screen's fetch is
    /// still running. The second fetch must not be skipped.
    @Test func fetchStartedDuringAnotherFetchStillLoads() async throws {
        let first = Task { await viewModel.fetchCategories(parentCatId: 1) }
        while await fetcher.requestedIds.isEmpty {
            await Task.yield()
        }
        #expect(viewModel.isLoading)

        await viewModel.fetchCategories(parentCatId: 2)
        await first.value

        #expect(await fetcher.requestedIds.sorted() == [1, 2])
        #expect(try storedParentIds() == [1, 2])
        #expect(!viewModel.isLoading)
    }

    private func storedParentIds() throws -> [Int] {
        try context.fetch(FetchDescriptor<CategoryEntity>()).map(\.parentId).sorted()
    }
}

/// Returns one child category per request, after a short delay so fetches overlap.
actor SlowCategoriesFetcher: CategoriesFetcher {
    private(set) var requestedIds: [Int] = []

    func fetchCategories(parentId: Int) async -> CategoryContainer {
        requestedIds.append(parentId)
        try? await Task.sleep(for: .milliseconds(100))
        return CategoryContainer(categories: [Category(id: parentId * 100, parentId: parentId, title: "child")], poems: [])
    }
}
