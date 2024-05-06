//
//  PoemMock.swift
//  Chakame
//
//  Created by Milad on 2024-02-18.
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

extension Poem {
    static let listMock = loadCategoryContainer().poems
    static let mock = loadCategoryContainer().poems.first
}
