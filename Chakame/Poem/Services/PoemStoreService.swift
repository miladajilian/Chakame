//
//  PoemStoreService.swift
//  Chakame
//
//  Created by Milad on 2024-02-18.
//

import SwiftData

@MainActor
struct PoemStoreService {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }
}

extension PoemStoreService: PoemStore {
    func update(poem: Poem) async throws {
        try poem.upsert(into: context)
        try context.save()
    }

    func toggleFavorite(_ poem: PoemEntity) throws {
        poem.isFavorite.toggle()
        try context.save()
    }
}
