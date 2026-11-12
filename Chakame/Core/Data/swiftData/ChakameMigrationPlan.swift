//
//  ChakameMigrationPlan.swift
//  Chakame
//

import Foundation
import SwiftData

enum ChakameMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [ChakameSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
