//
//  PreviewContainer.swift
//  Chakame
//

import Foundation
import SwiftData

/// In-memory container seeded with the bundled mock JSON, for Xcode previews.
@MainActor
enum PreviewContainer {
    static let shared: ModelContainer? = makeSeeded()

    /// The id of the seeded poem whose verses are stored.
    static var poemIdWithVerses: Int {
        Poem.mock?.id ?? 0
    }

    static func makeSeeded() -> ModelContainer? {
        do {
            let container = try ModelContainerFactory.make(inMemory: true)
            let context = container.mainContext
            for century in Century.mock.prefix(3) {
                try century.upsert(into: context)
            }
            for poem in Poem.listMock {
                try poem.upsert(into: context)
            }
            for verse in Verse.mock {
                try verse.upsert(into: context, poemId: poemIdWithVerses)
            }
            try context.save()
            return container
        } catch {
            print("Error creating preview container: \(error.localizedDescription)")
            return nil
        }
    }

    static func all<Model: PersistentModel>(_: Model.Type) -> [Model] {
        (try? shared?.mainContext.fetch(FetchDescriptor<Model>())) ?? []
    }

    static func first<Model: PersistentModel>(_ type: Model.Type) -> Model? {
        all(type).first
    }
}
