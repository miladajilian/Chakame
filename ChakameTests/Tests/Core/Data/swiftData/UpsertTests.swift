//
//  UpsertTests.swift
//  ChakameTests
//

@testable import Chakame
import Foundation
import SwiftData
import Testing

@MainActor
@Suite(.serialized)
struct UpsertTests {
    // Keep the container alive: a context whose container is deallocated crashes.
    let container: ModelContainer
    let context: ModelContext

    init() throws {
        container = try ModelContainerFactory.make(inMemory: true)
        context = container.mainContext
    }

    @Test func savingCenturiesTwiceDoesNotDuplicateCenturiesOrPoets() async throws {
        let store = CenturyStoreService(context: context)
        let hafez = Poet(id: 1, nickname: "حافظ")
        let centuries = [
            Century(id: 0, poets: [hafez]),
            Century(id: 8, name: "قرن هشتم", poets: [hafez, Poet(id: 2, nickname: "عبید")])
        ]

        try await store.save(centuries: centuries)
        try await store.save(centuries: centuries)

        #expect(try context.fetchCount(FetchDescriptor<CenturyEntity>()) == 2)
        #expect(try context.fetchCount(FetchDescriptor<PoetEntity>()) == 2)
        let shared = try #require(try context.first(where: #Predicate<PoetEntity> { $0.id == 1 }))
        #expect(Set(shared.centuries.map(\.id)) == [0, 8])
    }

    @Test func resavingAPoemKeepsFavoriteAndParent() async throws {
        let store = CategoryStoreService(context: context)
        try await store.save(poems: [Poem(id: 10, parentId: 5, title: "غزل ۱")])
        let poem = try #require(try context.first(where: #Predicate<PoemEntity> { $0.id == 10 }))
        try PoemStoreService(context: context).toggleFavorite(poem)

        // The single-poem endpoint has no parentId.
        try await PoemStoreService(context: context).update(poem: Poem(id: 10, fullTitle: "حافظ » غزل ۱"))
        try await store.save(poems: [Poem(id: 10, parentId: 5, title: "غزل ۱")])

        #expect(try context.fetchCount(FetchDescriptor<PoemEntity>()) == 1)
        #expect(poem.isFavorite)
        #expect(poem.parentId == 5)
        #expect(poem.title == "غزل ۱")
        #expect(poem.fullTitle == "حافظ » غزل ۱")
    }

    @Test func versesAreScopedByPoem() async throws {
        let store = VerseStoreService(context: context)
        try await store.save(verses: [Verse(id: 1, text: "a", vOrder: 1), Verse(id: 2, text: "b", vOrder: 2)], poemId: 10)
        try await store.save(verses: [Verse(id: 1, text: "a", vOrder: 1)], poemId: 10)

        #expect(try store.hasVerses(poemId: 10))
        #expect(try !store.hasVerses(poemId: 11))
        #expect(try context.fetchCount(FetchDescriptor<VerseEntity>()) == 2)
    }

    @Test func categoriesAreInsertedOnce() async throws {
        let store = CategoryStoreService(context: context)
        let categories = [Category(id: 3, parentId: 1, title: "غزلیات")]
        try await store.save(categories: categories)
        try await store.save(categories: categories)

        #expect(try context.fetchCount(FetchDescriptor<CategoryEntity>()) == 1)
    }
}
