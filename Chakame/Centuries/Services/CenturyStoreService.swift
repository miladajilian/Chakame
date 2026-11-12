//
//  CenturyStoreService.swift
//  Chakame
//
//  Created by Milad on 2024-01-28.
//

import SwiftData

/// Writes on the main context: on iOS 17, `@Query` doesn't reliably refresh after
/// saves from a background (`@ModelActor`) context.
@MainActor
struct CenturyStoreService {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }
}

extension CenturyStoreService: CenturyStore {
    func save(centuries: [Century]) async throws {
        for century in centuries {
            try century.upsert(into: context)
        }
        try context.save()
    }
}
