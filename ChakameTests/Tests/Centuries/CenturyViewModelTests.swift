//
//  CenturyViewModelTests.swift
//  ChakameTests
//

@testable import Chakame
import Foundation
import SwiftData
import Testing

@MainActor
@Suite(.serialized)
struct CenturyViewModelTests {
    let container: ModelContainer
    let viewModel: CenturyViewModel

    init() throws {
        container = try ModelContainerFactory.make(inMemory: true)
        let context = container.mainContext
        let poemViewModel = PoemViewModel(
            poemFetcher: PoemFetcherMock(),
            poemStore: PoemStoreService(context: context),
            verseStore: VerseStoreService(context: context)
        )
        viewModel = CenturyViewModel(
            isLoading: true,
            centuryFetcher: StubCenturiesFetcher(),
            centuryStore: CenturyStoreService(context: context),
            categoryViewModel: CategoryViewModel(
                categoriesFetcher: CategoriesFetcherMock(),
                categoryStore: CategoryStoreService(context: context),
                poemViewModel: poemViewModel
            )
        )
    }

    @Test func fetchCenturiesStopsLoadingAndStoresResults() async throws {
        #expect(viewModel.isLoading)
        await viewModel.fetchCenturies()
        #expect(!viewModel.isLoading)

        let centuries = try container.mainContext.fetch(FetchDescriptor<CenturyEntity>())
        #expect(centuries.count == 2)
    }

    @Test func centuryZeroIsTitledPopularPoets() {
        #expect(viewModel.getCenturyTitle(century: CenturyEntity(id: 0)) == String(localized: "Popular Poets"))
    }

    @Test func otherCenturiesUseTheirName() {
        let century = CenturyEntity(id: 4)
        century.name = "قرن چهارم"
        #expect(viewModel.getCenturyTitle(century: century) == "قرن چهارم")
    }
}

private struct StubCenturiesFetcher: CenturiesFetcher {
    func fetchCenturies() async -> [Century] {
        [
            Century(id: 0, poets: [Poet(id: 1, nickname: "حافظ")]),
            Century(id: 8, name: "قرن هشتم", poets: [Poet(id: 1, nickname: "حافظ")])
        ]
    }
}
