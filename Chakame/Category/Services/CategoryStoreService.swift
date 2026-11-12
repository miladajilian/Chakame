//
//  CategoryStoreService.swift
//  Chakame
//
//  Created by Milad on 2024-02-02.
//

import SwiftData

@MainActor
struct CategoryStoreService {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }
}

extension CategoryStoreService: CategoryStore {
    func save(categories: [Category]) async throws {
        guard !categories.isEmpty else { return }
        for category in categories {
            try category.upsert(into: context)
        }
        try context.save()
    }

    func save(poems: [Poem]) async throws {
        guard !poems.isEmpty else { return }
        for poem in poems {
            try poem.upsert(into: context)
        }
        try context.save()
    }
}
