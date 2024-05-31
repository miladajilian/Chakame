//
//  CenturyViewModel.swift
//  Chakame
//
//  Created by Milad on 2024-01-28.
//

import Foundation

protocol CenturyStore {
    func save(centuries: [Century]) async throws
}

protocol CenturiesFetcher {
    func fetchCenturies() async -> [Century]
}

@MainActor
final class CenturyViewModel: ObservableObject {
    @Published var isLoading: Bool
    private let centuryFetcher: CenturiesFetcher
    private let centuryStore: CenturyStore

    let categoryViewModel = CategoryViewModel()

    init(
        isLoading: Bool = true,
        centuryFetcher: CenturiesFetcher = FetchCenturiesService(requestManager: RequestManager.shared),
        centuryStore: CenturyStore = CenturyStoreService(
            context: PersistenceController.shared.container.newBackgroundContext())
    ) {
        self.isLoading = isLoading
        self.centuryFetcher = centuryFetcher
        self.centuryStore = centuryStore
    }

    func fetchCenturies() async {
        isLoading = true
        let centuries = await centuryFetcher.fetchCenturies()
        do {
            try await centuryStore.save(centuries: centuries)
        } catch {
            print("Error storing centuries... \(error.localizedDescription)")
        }
        self.isLoading = false
    }

    func getCenturyTitle(century: CenturyEntity) -> String {
        guard century.id != 0 else {
            return String(localized: "Popular Poets")
        }
       return century.name ?? ""
    }
}
