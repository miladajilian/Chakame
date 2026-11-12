//
//  VerseStoreService.swift
//  Chakame
//
//  Created by Milad on 2024-02-18.
//

import Foundation
import SwiftData

@MainActor
struct VerseStoreService {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }
}

extension VerseStoreService: VerseStore {
    func save(verses: [Verse], poemId: Int) async throws {
        guard !verses.isEmpty else { return }
        for verse in verses {
            try verse.upsert(into: context, poemId: poemId)
        }
        try context.save()
    }

    func hasVerses(poemId: Int) throws -> Bool {
        let descriptor = FetchDescriptor<VerseEntity>(predicate: #Predicate { $0.poemId == poemId })
        return try context.fetchCount(descriptor) > 0
    }
}
