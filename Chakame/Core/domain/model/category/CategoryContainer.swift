//
//  CategoryContainer.swift
//  Chakame
//
//  Created by Milad on 2024-01-30.
//

import Foundation

struct CategoryContainer: Decodable {
    var categories: [Category]
    var poems: [Poem]

    enum CodingKeys: String, CodingKey {
        case cat
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let cat = try container.decode(Category.self, forKey: .cat)
        categories = []
        poems = []
        if var children = cat.children, !children.isEmpty {
            children.indices.forEach {
                children[$0].parentId = cat.id
            }
            categories = children
        }
        if var poems = cat.poems, !poems.isEmpty {
            poems.indices.forEach {
                poems[$0].parentId = cat.id
            }
            self.poems = poems
        }
    }

    init(categories: [Category], poems: [Poem]) {
        self.categories = categories
        self.poems = poems
    }
}
