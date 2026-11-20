//
//  PoemSearchViewModel.swift
//  Chakame
//

import Foundation
import Observation

protocol PoemSearcher {
    func search(term: String, poetId: Int, catId: Int, page: Int, pageSize: Int) async throws -> [PoemSearchResult]
}

@MainActor
protocol PoemSearchStore {
    func save(results: [PoemSearchResult]) throws -> [PoemEntity]
}

/// Server search for one poet's poems, or for one of the poet's categories.
/// Each poet screen owns its own instance.
@Observable
@MainActor
final class PoemSearchViewModel {
    enum Phase: Equatable {
        /// Nothing searched yet: the user is still typing.
        case idle
        /// The submitted term is shorter than `minimumTermLength`; nothing was sent.
        case tooShort
        case loading
        case loaded
        case failed
    }

    static let minimumTermLength = 2
    /// Each result is large (the API sends the whole category tree), about 33 KB for Hafez,
    /// so pages stay small and more load as the list scrolls.
    static let pageSize = 10

    /// The results in order, cached so the reader can open and page through them.
    private(set) var poems: [PoemEntity] = []
    private(set) var phase: Phase = .idle
    private(set) var canLoadMore = false
    private(set) var isLoadingMore = false
    /// True when a later page failed; the poems already shown stay.
    private(set) var loadMoreFailed = false

    let poetId: Int
    let catId: Int

    @ObservationIgnored private let searcher: PoemSearcher
    @ObservationIgnored private let store: PoemSearchStore
    @ObservationIgnored private var term = ""
    @ObservationIgnored private var page = 0
    @ObservationIgnored private var searchTask: Task<Void, Never>?

    init(poetId: Int, catId: Int, searcher: PoemSearcher, store: PoemSearchStore) {
        self.poetId = poetId
        self.catId = catId
        self.searcher = searcher
        self.store = store
    }

    /// Runs a search for `rawTerm` when the user presses Search. Repeating the search that is
    /// already showing or loading sends nothing. A new term cancels the request still running.
    @discardableResult
    func submit(term rawTerm: String) -> Task<Void, Never>? {
        let term = rawTerm.trimmingCharacters(in: .whitespacesAndNewlines)
        if term == self.term, phase == .loaded || phase == .loading {
            return nil
        }
        searchTask?.cancel()
        // Set the state now, not when the task starts, so a second press is seen at once.
        guard begin(term: term) else {
            searchTask = nil
            return nil
        }
        let task = Task { await fetchFirstPage(of: term) }
        searchTask = task
        return task
    }

    /// Stops any running search and clears the results, for example when the field is cleared.
    func cancel() {
        searchTask?.cancel()
        searchTask = nil
        reset(term: "")
        phase = .idle
    }

    /// Starts a new search. Terms shorter than `minimumTermLength` clear the results.
    func search(term rawTerm: String) async {
        let term = rawTerm.trimmingCharacters(in: .whitespacesAndNewlines)
        guard begin(term: term) else { return }
        await fetchFirstPage(of: term)
    }

    /// Clears the previous results and marks `term` as loading. Returns false, without asking
    /// the server, when the term is too short.
    private func begin(term: String) -> Bool {
        reset(term: term)
        guard term.count >= Self.minimumTermLength else {
            phase = .tooShort
            return false
        }
        phase = .loading
        return true
    }

    private func reset(term: String) {
        self.term = term
        page = 0
        poems = []
        canLoadMore = false
        isLoadingMore = false
        loadMoreFailed = false
    }

    private func fetchFirstPage(of term: String) async {
        do {
            let results = try await searcher.search(
                term: term, poetId: poetId, catId: catId, page: 1, pageSize: Self.pageSize
            )
            guard isCurrent(term) else { return }
            poems = try store.save(results: results)
            page = 1
            canLoadMore = results.count == Self.pageSize
            phase = .loaded
        } catch {
            guard isCurrent(term) else { return }
            print("Error searching poems... \(error.localizedDescription)")
            phase = .failed
        }
    }

    /// Fetches and appends the next page of the current search. After a failed page it waits
    /// for `retry()` instead of trying again every time the last row scrolls into view.
    func loadMore() async {
        guard phase == .loaded, canLoadMore, !isLoadingMore, !loadMoreFailed else { return }
        let term = term
        let nextPage = page + 1
        isLoadingMore = true
        defer {
            if isCurrent(term) {
                isLoadingMore = false
            }
        }
        do {
            let results = try await searcher.search(
                term: term, poetId: poetId, catId: catId, page: nextPage, pageSize: Self.pageSize
            )
            guard isCurrent(term) else { return }
            let known = Set(poems.map(\.id))
            poems += try store.save(results: results.filter { !known.contains($0.id) })
            page = nextPage
            canLoadMore = results.count == Self.pageSize
        } catch {
            guard isCurrent(term) else { return }
            print("Error loading more poems... \(error.localizedDescription)")
            loadMoreFailed = true
        }
    }

    /// Runs the failed request again: the whole search, or the page that didn't load.
    @discardableResult
    func retry() -> Task<Void, Never>? {
        if phase == .failed {
            return submit(term: term)
        }
        guard loadMoreFailed else { return nil }
        loadMoreFailed = false
        return Task { await loadMore() }
    }

    private func isCurrent(_ searchedTerm: String) -> Bool {
        !Task.isCancelled && searchedTerm == term
    }
}
