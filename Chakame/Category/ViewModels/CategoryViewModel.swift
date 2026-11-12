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
    var isLoading: Bool

    @ObservationIgnored private let categoriesFetcher: CategoriesFetcher
    @ObservationIgnored private let categoryStore: CategoryStore

    let poemViewModel: PoemViewModel

    init(
        isLoading: Bool = false,
        categoriesFetcher: CategoriesFetcher = FetchCategoriesService(requestManager: RequestManager.shared),
        categoryStore: CategoryStore,
        poemViewModel: PoemViewModel
    ) {
        self.isLoading = isLoading
        self.categoriesFetcher = categoriesFetcher
        self.categoryStore = categoryStore
        self.poemViewModel = poemViewModel
    }

    func fetchCategories(parentCatId: Int) async {
        guard isLoading == false else { return }

        isLoading = true
        defer { isLoading = false }
        let categoryContainer = await categoriesFetcher.fetchCategories(parentId: parentCatId)
        do {
            try await categoryStore.save(categories: categoryContainer.categories)
            try await categoryStore.save(poems: categoryContainer.poems)
        } catch {
            print("Error storing categories... \(error.localizedDescription)")
        }
    }
}
