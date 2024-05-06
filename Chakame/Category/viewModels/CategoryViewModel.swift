//
//  CategoryViewModel.swift
//  Chakame
//
//  Created by Milad on 2024-01-30.
//

import Foundation
import CoreData

protocol CategoryStore {
    func save(categories: [Category]) async throws
    func save(poems: [Poem]) async throws
}

protocol CategoriesFetcher {
    func fetchCategories(parentId: Int) async -> CategoryContainer
}

@MainActor
final class CategoryViewModel: ObservableObject {
    @Published var isLoading: Bool
    @Published var categories: [CategoryEntity] = []
    @Published var poems: [PoemEntity] = []
    
    let parentCatId: Int
    
    private(set) var categoriesFetcher: CategoriesFetcher
    private(set) var categoryStore: CategoryStore
    
    init(
        isLoading: Bool  = false,
        parentCatId: Int,
        categoriesFetcher: CategoriesFetcher,
        categoryStore: CategoryStore
    ) {
        self.isLoading = isLoading
        self.parentCatId = parentCatId
        self.categoriesFetcher = categoriesFetcher
        self.categoryStore = categoryStore
    }
    
    
    @MainActor func fetchCategories() async {
        guard isLoading == false else { return }
        
        isLoading = true
        let categoryContainer = await categoriesFetcher.fetchCategories(parentId: parentCatId)
        do {
            try await categoryStore.save(
                categories: categoryContainer.categories
            )
            try await categoryStore.save(
                poems: categoryContainer.poems
            )
            self.isLoading = false
        } catch {
            print("Error storing categories... \(error.localizedDescription)")
            self.isLoading = false
        }
    }

    func getCategoryFetchRequest() -> NSFetchRequest<CategoryEntity> {
        let categoryRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        categoryRequest.predicate = NSPredicate(
            format: "parentId = \(parentCatId)"
        )
        
        categoryRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \CategoryEntity.title, ascending: true)
        ]
        return categoryRequest
    }
    func getPoemFetchRequest() -> NSFetchRequest<PoemEntity> {
        let poemsRequest: NSFetchRequest<PoemEntity> = PoemEntity.fetchRequest()
        poemsRequest.predicate = NSPredicate(
            format: "parentId = \(parentCatId)"
        )
        
        poemsRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \PoemEntity.id, ascending: true)
        ]
        return poemsRequest
    }
}
