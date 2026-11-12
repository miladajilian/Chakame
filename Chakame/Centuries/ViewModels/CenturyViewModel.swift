//
//  CenturyViewModel.swift
//  Chakame
//
//  Created by Milad on 2024-01-28.
//

import Foundation
import Observation

@MainActor
protocol CenturyStore {
    func save(centuries: [Century]) async throws
}

protocol CenturiesFetcher {
    func fetchCenturies() async -> [Century]
}

@Observable
@MainActor
final class CenturyViewModel {
    var isLoading: Bool

    @ObservationIgnored private let centuryFetcher: CenturiesFetcher
    @ObservationIgnored private let centuryStore: CenturyStore

    let categoryViewModel: CategoryViewModel

    init(
        isLoading: Bool = true,
        centuryFetcher: CenturiesFetcher = FetchCenturiesService(requestManager: RequestManager.shared),
        centuryStore: CenturyStore,
        categoryViewModel: CategoryViewModel
    ) {
        self.isLoading = isLoading
        self.centuryFetcher = centuryFetcher
        self.centuryStore = centuryStore
        self.categoryViewModel = categoryViewModel
    }

    func fetchCenturies() async {
        isLoading = true
        let centuries = await centuryFetcher.fetchCenturies()
        do {
            try await centuryStore.save(centuries: centuries)
        } catch {
            print("Error storing centuries... \(error.localizedDescription)")
        }
        isLoading = false
    }

    func getCenturyTitle(century: CenturyEntity) -> String {
        guard century.id != 0 else {
            return String(localized: "Popular Poets")
        }
        return century.name
    }
}
