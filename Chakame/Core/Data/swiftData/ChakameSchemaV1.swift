//
//  ChakameSchemaV1.swift
//  Chakame
//

import Foundation
import SwiftData

/// First SwiftData schema. Any model change needs a new `VersionedSchema`
/// and a stage in `ChakameMigrationPlan`.
enum ChakameSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            CenturyEntity.self,
            PoetEntity.self,
            CategoryEntity.self,
            PoemEntity.self,
            VerseEntity.self
        ]
    }
}
