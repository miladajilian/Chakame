//
//  PoemSearchResult.swift
//  Chakame
//

import Foundation

/// One poem from `/api/ganjoor/poems/search`.
///
/// The API sends the full `GanjoorPoemCompleteViewModel`; only the fields the app uses are
/// decoded. Search results have no `parentId` and no verses.
struct PoemSearchResult: Decodable, Identifiable {
    var id: Int
    var title: String?
    var fullTitle: String?
    var urlSlug: String?
    var plainText: String?

    /// The poem's first non-empty line, shown under the title like a category's excerpt.
    var excerpt: String {
        let lines = (plainText ?? "").components(separatedBy: .newlines)
        let first = lines.first { !$0.trimmingCharacters(in: .whitespaces).isEmpty } ?? ""
        return first.trimmingCharacters(in: .whitespaces)
    }

    /// The cached-poem form. `parentId` stays nil so an upsert keeps the poem's category.
    var poem: Poem {
        Poem(id: id, title: title, urlSlug: urlSlug, fullTitle: fullTitle, excerpt: excerpt)
    }
}
