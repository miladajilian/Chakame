//
//  CategoryViewModel.swift
//  Chakame
//
//  Created by Milad on 2024-01-30.
//

import Foundation
import Observation

@MainActor
protocol CategoryStore {
    func save(categories: [Category]) async throws
    func save(poems: [Poem]) async throws
}

protocol CategoriesFetcher {
    func fetchCategories(parentId: Int) async -> CategoryContainer
}

@Observable
@MainActor
final class CategoryViewModel {
    /// True while any category screen is fetching.
    var isLoading: Bool {
        activeFetches > 0
    }

    private var activeFetches = 0

    @ObservationIgnored private let categoriesFetcher: CategoriesFetcher
    @ObservationIgnored private let categoryStore: CategoryStore

    let poemViewModel: PoemViewModel

    init(
        categoriesFetcher: CategoriesFetcher = FetchCategoriesService(requestManager: RequestManager.shared),
        categoryStore: CategoryStore,
        poemViewModel: PoemViewModel
    ) {
        self.categoriesFetcher = categoriesFetcher
        self.categoryStore = categoryStore
        self.poemViewModel = poemViewModel
    }

    /// Downloads and stores a category's children. Every call fetches, even while another fetch
    /// is running: SwiftUI can rebuild a screen and cancel its first task (for example when the
    /// iPad sidebar switches poets), and the rebuilt screen must still load. Repeats are
    /// harmless because the store upserts.
    func fetchCategories(parentCatId: Int) async {
        activeFetches += 1
        defer { activeFetches -= 1 }
        let categoryContainer = await categoriesFetcher.fetchCategories(parentId: parentCatId)
        do {
            try await categoryStore.save(categories: categoryContainer.categories)
            try await categoryStore.save(poems: categoryContainer.poems)
        } catch {
            print("Error storing categories... \(error.localizedDescription)")
        }
    }
}
