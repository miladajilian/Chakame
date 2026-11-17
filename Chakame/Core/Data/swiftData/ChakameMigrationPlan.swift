//
//  ChakameMigrationPlan.swift
//  Chakame
//

import Foundation
import SwiftData

enum ChakameMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [ChakameSchemaV1.self, ChakameSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }

    /// V2 only adds `PoemEntity.excerpt`, which has a default.
    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: ChakameSchemaV1.self,
        toVersion: ChakameSchemaV2.self
    )
}
