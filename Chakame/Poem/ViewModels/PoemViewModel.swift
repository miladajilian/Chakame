//
//  PoemViewModel.swift
//  Chakame
//
//  Created by Milad on 2024-02-18.
//

import Foundation
import Observation

@MainActor
protocol VerseStore {
    func save(verses: [Verse], poemId: Int) async throws
    func hasVerses(poemId: Int) throws -> Bool
}

@MainActor
protocol PoemStore {
    func update(poem: Poem) async throws
    func toggleFavorite(_ poem: PoemEntity) throws
}

protocol PoemFetcher {
    func fetchVerses(poemId: Int) async -> [Verse]
    func fetchPoem(poemId: Int) async -> Poem?
}

@Observable
@MainActor
final class PoemViewModel {
    var isLoading: Bool

    @ObservationIgnored private let poemFetcher: PoemFetcher
    @ObservationIgnored private let poemStore: PoemStore
    @ObservationIgnored private let verseStore: VerseStore

    init(
        isLoading: Bool = false,
        poemFetcher: PoemFetcher = FetchPoemService(requestManager: RequestManager.shared),
        poemStore: PoemStore,
        verseStore: VerseStore
    ) {
        self.isLoading = isLoading
        self.poemFetcher = poemFetcher
        self.poemStore = poemStore
        self.verseStore = verseStore
    }

    func fetchVerses(poem: PoemEntity) {
        let poemId = poem.id
        Task {
            await fetchVerses(poemId: poemId)
        }
    }

    /// Downloads and stores a poem's verses, unless they're already stored.
    func fetchVerses(poemId: Int) async {
        let alreadyStored = (try? verseStore.hasVerses(poemId: poemId)) ?? false
        guard !alreadyStored else { return }

        isLoading = true
        defer { isLoading = false }
        guard let poem = await poemFetcher.fetchPoem(poemId: poemId) else { return }
        do {
            try await verseStore.save(verses: poem.verses ?? [], poemId: poemId)
            try await poemStore.update(poem: poem)
        } catch {
            print("Error storing verses ... \(error.localizedDescription)")
        }
    }

    func toggleFavorite(poem: PoemEntity) {
        do {
            try poemStore.toggleFavorite(poem)
        } catch {
            print("Error updating poem isFavorite ... \(error.localizedDescription)")
        }
    }
}
