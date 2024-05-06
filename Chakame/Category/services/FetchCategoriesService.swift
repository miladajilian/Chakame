//
//  FetchCategoriesService.swift
//  Chakame
//
//  Created by Milad on 2024-02-02.
//

import Foundation
struct FetchCategoriesService {
    private let requestManager: RequestManagerProtocol
    
    init(requestManager: RequestManagerProtocol) {
        self.requestManager = requestManager
    }
}

extension FetchCategoriesService: CategoriesFetcher {
    func fetchCategories(parentId: Int) async -> CategoryContainer {
        let requestData = ChakameRequest.getCategories(parentId: "\(parentId)")
        do {
            let categoriesContainer: CategoryContainer = try await requestManager.perform(requestData)
            return categoriesContainer
        } catch {
            print(error.localizedDescription)
            return CategoryContainer(categories: [], poems: [])
        }
    }
    
}
