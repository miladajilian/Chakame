//
//  Poem+SwiftData.swift
//  Chakame
//

import Foundation
import SwiftData

extension Poem {
    /// Inserts the poem, or updates the stored one.
    ///
    /// Updates never clear a value the API left out, and never touch `isFavorite`.
    /// For example, the single-poem endpoint has no `parentId`, so overwriting it
    /// would hide the poem from its category.
    @discardableResult
    func upsert(into context: ModelContext) throws -> PoemEntity {
        let poemId = id
        let entity: PoemEntity
        if let existing = try context.first(where: #Predicate<PoemEntity> { $0.id == poemId }) {
            entity = existing
        } else {
            entity = PoemEntity(id: id)
            context.insert(entity)
        }
        if let parentId {
            entity.parentId = parentId
        }
        if let nextId = next?.id {
            entity.nextId = nextId
        }
        if let previousId = previous?.id {
            entity.previousId = previousId
        }
        if let title {
            entity.title = title
        }
        if let fullTitle {
            entity.fullTitle = fullTitle
        }
        if let urlSlug {
            entity.urlSlug = urlSlug
        }
        return entity
    }
}
