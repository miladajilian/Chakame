//
//  CategoryRoute.swift
//  Chakame
//

import Foundation

/// Navigation value for a category screen. Destinations are registered with
/// `navigationDestination(for:)` on each tab's `NavigationStack`.
struct CategoryRoute: Hashable {
    let id: Int
    let title: String
    /// The poet the category belongs to, for searching the poet's poems.
    let poetId: Int
    /// True for the poet's root category, where search covers all of the poet's poems.
    var isPoetRoot = false

    /// The poet's main screen.
    init(poet: PoetEntity) {
        self.init(id: poet.rootCatId, title: poet.nickname, poetId: poet.id, isPoetRoot: true)
    }

    init(id: Int, title: String, poetId: Int, isPoetRoot: Bool = false) {
        self.id = id
        self.title = title
        self.poetId = poetId
        self.isPoetRoot = isPoetRoot
    }

    /// The category to narrow a search to: none at the poet's root.
    var searchCatId: Int {
        isPoetRoot ? 0 : id
    }
}
