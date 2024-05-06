//
//  CategoryFetcherMock.swift
//  Chakame
//
//  Created by Milad on 2024-02-02.
//

import Foundation

struct CategoriesFetcherMock: CategoriesFetcher {
    func fetchCategories(parentId: Int) async -> CategoryContainer {
        Category.categoryContainerMock
    }
}
