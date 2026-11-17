//
//  ChakameSchemaV1.swift
//  Chakame
//

import Foundation
import SwiftData

/// First SwiftData schema, frozen. Its models are nested copies (see `ChakameSchemaV1+Models.swift`)
/// so its checksum keeps matching stores created by older app versions. Don't edit them.
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
