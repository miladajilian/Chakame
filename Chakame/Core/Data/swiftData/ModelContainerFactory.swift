//
//  ModelContainerFactory.swift
//  Chakame
//

import Foundation
import SwiftData

enum ModelContainerFactory {
    static let storeFileName = "Chakame.store"

    /// Creates the app's container. Pass `inMemory: true` for tests and previews.
    static func make(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema(versionedSchema: ChakameSchemaV1.self)
        let configuration: ModelConfiguration
        if inMemory {
            configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        } else {
            let directory = URL.applicationSupportDirectory
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            configuration = ModelConfiguration(schema: schema, url: directory.appending(path: storeFileName))
        }
        return try ModelContainer(
            for: schema,
            migrationPlan: ChakameMigrationPlan.self,
            configurations: configuration
        )
    }
}
