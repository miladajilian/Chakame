//
//  CachingPoemSearcher.swift
//  Chakame
//

import Foundation

/// Wraps a `PoemSearcher` to go easy on Ganjoor's server.
///
/// - Pages already fetched in the last `lifetime` come from memory, so searching the same words
///   again (on any poet screen, or after going back) sends nothing.
/// - Requests that do reach the server start at least `minimumInterval` apart.
///
/// One instance is shared by every search screen. Failures aren't cached.
actor CachingPoemSearcher: PoemSearcher {
    private struct Key: Hashable {
        let term: String
        let poetId: Int
        let catId: Int
        let page: Int
        let pageSize: Int
    }

    private struct Entry {
        let results: [PoemSearchResult]
        let storedAt: ContinuousClock.Instant
    }

    private let base: PoemSearcher
    private let minimumInterval: Duration
    private let lifetime: Duration
    private let capacity: Int
    private let clock = ContinuousClock()

    private var cache: [Key: Entry] = [:]
    /// Keys from oldest to newest, for dropping the oldest page when the cache is full.
    private var order: [Key] = []
    /// When the most recent request was allowed to start.
    private var lastRequestStart: ContinuousClock.Instant?

    init(
        base: PoemSearcher,
        minimumInterval: Duration = .seconds(1),
        lifetime: Duration = .seconds(30 * 60),
        capacity: Int = 100
    ) {
        self.base = base
        self.minimumInterval = minimumInterval
        self.lifetime = lifetime
        self.capacity = capacity
    }

    func search(term: String, poetId: Int, catId: Int, page: Int, pageSize: Int) async throws -> [PoemSearchResult] {
        let key = Key(term: term, poetId: poetId, catId: catId, page: page, pageSize: pageSize)
        if let entry = cache[key], clock.now - entry.storedAt < lifetime {
            return entry.results
        }

        try await waitForTurn()
        let results = try await base.search(
            term: term, poetId: poetId, catId: catId, page: page, pageSize: pageSize
        )
        store(results, for: key)
        return results
    }

    /// Spaces requests out. The start time is reserved before sleeping, so requests that arrive
    /// together line up one `minimumInterval` apart. A cancelled wait sends nothing.
    private func waitForTurn() async throws {
        let now = clock.now
        let start = lastRequestStart.map { max(now, $0 + minimumInterval) } ?? now
        lastRequestStart = start
        if start > now {
            try await clock.sleep(until: start)
        }
    }

    private func store(_ results: [PoemSearchResult], for key: Key) {
        if cache[key] == nil {
            order.append(key)
        }
        cache[key] = Entry(results: results, storedAt: clock.now)
        while order.count > capacity {
            cache[order.removeFirst()] = nil
        }
    }
}
