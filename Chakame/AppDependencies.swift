//
//  AppDependencies.swift
//  Chakame
//

import SwiftData

/// Builds the store services and view models from one `ModelContainer`.
@MainActor
struct AppDependencies {
    let centuryViewModel: CenturyViewModel
    let poemViewModel: PoemViewModel

    init(
        container: ModelContainer,
        centuriesFetcher: CenturiesFetcher = FetchCenturiesService(requestManager: RequestManager.shared),
        categoriesFetcher: CategoriesFetcher = FetchCategoriesService(requestManager: RequestManager.shared),
        poemFetcher: PoemFetcher = FetchPoemService(requestManager: RequestManager.shared)
    ) {
        let context = container.mainContext
        let poemViewModel = PoemViewModel(
            poemFetcher: poemFetcher,
            poemStore: PoemStoreService(context: context),
            verseStore: VerseStoreService(context: context)
        )
        let categoryViewModel = CategoryViewModel(
            categoriesFetcher: categoriesFetcher,
            categoryStore: CategoryStoreService(context: context),
            poemViewModel: poemViewModel
        )
        self.poemViewModel = poemViewModel
        self.centuryViewModel = CenturyViewModel(
            centuryFetcher: centuriesFetcher,
            centuryStore: CenturyStoreService(context: context),
            categoryViewModel: categoryViewModel
        )
    }

    /// Mock fetchers and the seeded in-memory container, for previews.
    static func preview(container: ModelContainer) -> AppDependencies {
        AppDependencies(
            container: container,
            centuriesFetcher: CenturiesFetcherMock(),
            categoriesFetcher: CategoriesFetcherMock(),
            poemFetcher: PoemFetcherMock()
        )
    }
}
