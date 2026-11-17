//
//  ChakameSchemaV2.swift
//  Chakame
//

import Foundation
import SwiftData

/// Current schema. Adds `PoemEntity.excerpt` (the poem's first line).
enum ChakameSchemaV2: VersionedSchema {
    static let versionIdentifier = Schema.Version(2, 0, 0)

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
