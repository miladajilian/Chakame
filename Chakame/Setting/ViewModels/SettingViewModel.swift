//
//  SettingViewModel.swift
//  Chakame
//

import Foundation
import Observation

@MainActor
protocol CacheStore {
    /// Removes the cached Ganjoor data. Favorite poems stay.
    func clearCache() throws
}

@Observable
@MainActor
final class SettingViewModel {
    enum RefreshState: Equatable {
        case idle
        case refreshing
        case refreshed
        case failed
    }

    var refreshState: RefreshState = .idle
    /// Bumped after every clear, so views that showed cached data can rebuild from scratch.
    private(set) var cacheGeneration = 0

    @ObservationIgnored private let cacheStore: CacheStore
    @ObservationIgnored private let reload: @MainActor () async -> Void

    /// - Parameter reload: Downloads the first screen again (the poet list) after the cache is cleared.
    init(cacheStore: CacheStore, reload: @escaping @MainActor () async -> Void) {
        self.cacheStore = cacheStore
        self.reload = reload
    }

    /// Clears the cached Ganjoor data and downloads the poet list again.
    /// Categories, poems and verses are downloaded again as the user opens them.
    func refreshFromGanjoor() async {
        guard refreshState != .refreshing else { return }

        refreshState = .refreshing
        do {
            try cacheStore.clearCache()
        } catch {
            print("Error clearing the cache... \(error.localizedDescription)")
            refreshState = .failed
            return
        }
        cacheGeneration += 1
        await reload()
        refreshState = .refreshed
    }
}
