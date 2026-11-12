//
//  PoemViewModelTests.swift
//  ChakameTests
//

@testable import Chakame
import Foundation
import SwiftData
import Testing

@MainActor
@Suite(.serialized)
struct PoemViewModelTests {
    // Keep the container alive: a context whose container is deallocated crashes.
    let container: ModelContainer
    let context: ModelContext
    let fetcher = CountingPoemFetcher()
    let viewModel: PoemViewModel

    init() throws {
        container = try ModelContainerFactory.make(inMemory: true)
        context = container.mainContext
        viewModel = PoemViewModel(
            poemFetcher: fetcher,
            poemStore: PoemStoreService(context: context),
            verseStore: VerseStoreService(context: context)
        )
    }

    @Test func fetchVersesStoresVersesAndStopsLoading() async throws {
        await viewModel.fetchVerses(poemId: 10)

        #expect(!viewModel.isLoading)
        #expect(fetcher.fetchPoemCalls == 1)
        #expect(try context.fetchCount(FetchDescriptor<VerseEntity>()) == 2)
    }

    @Test func fetchVersesSkipsTheNetworkWhenVersesAreStored() async {
        await viewModel.fetchVerses(poemId: 10)
        await viewModel.fetchVerses(poemId: 10)

        #expect(fetcher.fetchPoemCalls == 1)
    }

    @Test func toggleFavoritePersists() throws {
        let poem = PoemEntity(id: 10)
        context.insert(poem)

        viewModel.toggleFavorite(poem: poem)
        let favorites = try context.fetch(FetchDescriptor<PoemEntity>(predicate: #Predicate { $0.isFavorite }))
        #expect(favorites.map(\.id) == [10])

        viewModel.toggleFavorite(poem: poem)
        #expect(!poem.isFavorite)
    }
}

final class CountingPoemFetcher: PoemFetcher {
    private(set) var fetchPoemCalls = 0

    func fetchVerses(poemId: Int) async -> [Verse] {
        []
    }

    func fetchPoem(poemId: Int) async -> Poem? {
        fetchPoemCalls += 1
        return Poem(id: poemId, verses: [Verse(id: 1, text: "a", vOrder: 1), Verse(id: 2, text: "b", vOrder: 2)])
    }
}
