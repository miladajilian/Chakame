//
//  PoemViewModel.swift
//  Chakame
//
//  Created by Milad on 2024-02-18.
//

import Foundation
import CoreData

protocol VerseStore {
    func save(verses: [Verse], poemId: Int32) async throws
}
protocol PoemStore {
    func update(poem: Poem) async throws
}

protocol PoemFetcher {
    func fetchVerses(poemId: Int32) async -> [Verse]
    func fetchPoem(poemId: Int32) async -> Poem?
}

@MainActor
final class PoemViewModel: ObservableObject {
    @Published var isLoading: Bool
    @Published var isFavorite: Bool = false

    private var poemFetcher: PoemFetcher
    private var verseStore: VerseStore = VerseStoreService()
    private var poemStore: PoemStore

    init(
        isLoading: Bool  = false,
        poemFetcher: PoemFetcher = FetchPoemService(requestManager: RequestManager.shared),
        poemStore: PoemStore = PoemStoreService(context: PersistenceController.shared.container.newBackgroundContext())
    ) {
        self.isLoading = isLoading
        self.poemFetcher = poemFetcher
        self.poemStore = poemStore
    }

    func fetchVerses(poem: PoemEntity) {
        Task {
            await self.fetchVerses(poemId: poem.id)
        }
    }
    private func fetchVerses(poemId: Int32) async {
        guard !checkForExistingVerse(poemId: poemId) else { return }
        isLoading = true
        guard let poem = await poemFetcher.fetchPoem(poemId: poemId) else {
            return
        }
        do {
            try await verseStore.save(
                verses: poem.verses ?? [],
                poemId: poemId
            )

            try await poemStore.update(poem: poem)

            self.isLoading = false
        } catch {
            print("Error storing verses ... \(error.localizedDescription)")
            self.isLoading = false
        }
    }

    private func checkForExistingVerse
    (
        poemId: Int32,
        context: NSManagedObjectContext = PersistenceController.shared.container.viewContext
    ) -> Bool {
        let fetchRequest = VerseEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "poemId = \(poemId)"
        )

        if let results = try? context.fetch(fetchRequest), results.first != nil {
            return true
        }
        return false
    }

    func toggleFavorite(poem: PoemEntity) {
        Task {
            do {
                poem.isFavorite.toggle()
                self.isFavorite.toggle()
                try poem.managedObjectContext?.save()
            } catch {
                print("Error updating poem isFavotite ... \(error.localizedDescription)")
            }
        }
    }
}
