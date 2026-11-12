//
//  SettingViewModelTests.swift
//  ChakameTests
//

@testable import Chakame
import Foundation
import SwiftData
import Testing

@MainActor
@Suite(.serialized)
struct SettingViewModelTests {
    // Keep the container alive: a context whose container is deallocated crashes.
    let container: ModelContainer
    let context: ModelContext

    init() throws {
        container = try ModelContainerFactory.make(inMemory: true)
        context = container.mainContext
    }

    @Test func clearCacheRemovesApiDataAndKeepsFavorites() throws {
        try seedStore()

        try CacheStoreService(context: context).clearCache()

        #expect(try context.fetchCount(FetchDescriptor<CenturyEntity>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<PoetEntity>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<CategoryEntity>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<VerseEntity>()) == 0)

        let poems = try context.fetch(FetchDescriptor<PoemEntity>())
        #expect(poems.map(\.id) == [2])
        #expect(poems.first?.isFavorite == true)
        #expect(poems.first?.title == "غزل ۲")
        // Detached, so its category downloads again instead of showing only the favorite.
        #expect(poems.first?.parentId == 0)
    }

    @Test func refreshClearsThenReloads() async {
        let store = RecordingCacheStore()
        var reloads = 0
        let viewModel = SettingViewModel(cacheStore: store, reload: { reloads += 1 })

        await viewModel.refreshFromGanjoor()

        #expect(store.clearCalls == 1)
        #expect(reloads == 1)
        #expect(viewModel.cacheGeneration == 1)
        #expect(viewModel.refreshState == .refreshed)
    }

    @Test func failedClearSkipsReloadAndReportsFailure() async {
        let store = RecordingCacheStore(shouldFail: true)
        var reloads = 0
        let viewModel = SettingViewModel(cacheStore: store, reload: { reloads += 1 })

        await viewModel.refreshFromGanjoor()

        #expect(reloads == 0)
        #expect(viewModel.cacheGeneration == 0)
        #expect(viewModel.refreshState == .failed)
    }

    private func seedStore() throws {
        let century = CenturyEntity(id: 8)
        let poet = PoetEntity(id: 1)
        century.poets = [poet]
        context.insert(century)

        let category = CategoryEntity(id: 24)
        category.parentId = 2
        context.insert(category)

        let poem = PoemEntity(id: 1)
        poem.parentId = 24
        context.insert(poem)

        let favorite = PoemEntity(id: 2)
        favorite.parentId = 24
        favorite.title = "غزل ۲"
        favorite.isFavorite = true
        context.insert(favorite)

        let verse = VerseEntity(id: 100)
        verse.poemId = 2
        context.insert(verse)

        try context.save()
    }
}

@MainActor
private final class RecordingCacheStore: CacheStore {
    struct ClearError: Error {}

    private let shouldFail: Bool
    private(set) var clearCalls = 0

    init(shouldFail: Bool = false) {
        self.shouldFail = shouldFail
    }

    func clearCache() throws {
        clearCalls += 1
        if shouldFail {
            throw ClearError()
        }
    }
}
