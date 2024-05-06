//
//  CategoryMock.swift
//  Chakame
//
//  Created by Milad on 2024-01-31.
//

import Foundation

private func loadCategoryContainer() -> CategoryContainer {
    guard let url = Bundle.main.url(forResource: "CategoriesMock", withExtension: "json"),
          let data = try? Data(contentsOf: url) else {
        return CategoryContainer(categories: [], poems: [])
    }
    let decoder = JSONDecoder()
    let jsonMock = try? decoder.decode(CategoryContainer.self, from: data)
    return jsonMock ?? CategoryContainer(categories: [], poems: [])
}

extension Category {
    static let categoriesMock = loadCategoryContainer().categories
    static let categoryContainerMock = loadCategoryContainer()
}
