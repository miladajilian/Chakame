//
//  Category.swift
//  Chakame
//
//  Created by Milad on 2024-01-30.
//

import Foundation

struct Category: Codable {
    var id: Int
    var parentId: Int?
    var title: String?
    var urlSlug: String?
    var fullUrl: String?
    var children: [Category]?
    var poems: [Poem]?
}

// MARK: - Identifiable
extension Category: Identifiable {
}
