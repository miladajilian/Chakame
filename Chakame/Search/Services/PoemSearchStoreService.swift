//
//  PoemSearchStoreService.swift
//  Chakame
//

import SwiftData

@MainActor
struct PoemSearchStoreService {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }
}

extension PoemSearchStoreService: PoemSearchStore {
    /// Caches the results so the reader can open them. A poem that wasn't cached yet gets
    /// `parentId == 0` and stays out of category lists until its category is fetched.
    func save(results: [PoemSearchResult]) throws -> [PoemEntity] {
        guard !results.isEmpty else { return [] }
        let entities = try results.map { try $0.poem.upsert(into: context) }
        try context.save()
        return entities
    }
}
