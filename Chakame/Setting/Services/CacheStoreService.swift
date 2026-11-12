//
//  CacheStoreService.swift
//  Chakame
//

import Foundation
import SwiftData

/// Deletes the cached Ganjoor data on the main context, so every `@Query` refreshes.
@MainActor
struct CacheStoreService {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }
}

extension CacheStoreService: CacheStore {
    func clearCache() throws {
        try deleteAll(of: VerseEntity.self)
        try deleteAll(of: CategoryEntity.self)
        try deleteAll(of: PoetEntity.self)
        try deleteAll(of: CenturyEntity.self)
        try deleteAll(of: PoemEntity.self, where: #Predicate { !$0.isFavorite })

        // Favorites are user data, so they stay. Detach them from their category:
        // `CategoryView` only downloads a category when it has nothing stored, and a
        // lone favorite would hide the rest of its poems. The next category download
        // sets `parentId` again.
        let favorites = try context.fetch(FetchDescriptor<PoemEntity>(predicate: #Predicate { $0.isFavorite }))
        for poem in favorites {
            poem.parentId = 0
        }
        try context.save()
    }

    private func deleteAll<Model: PersistentModel>(
        of type: Model.Type,
        where predicate: Predicate<Model>? = nil
    ) throws {
        // Deleted one by one, not with `delete(model:where:)`: on iOS 17 the batch
        // delete doesn't reliably update `@Query` or the many-to-many poet relationship.
        for model in try context.fetch(FetchDescriptor<Model>(predicate: predicate)) {
            context.delete(model)
        }
    }
}
