//
//  PoemSearchSection.swift
//  Chakame
//

import SwiftUI

/// The "Poems" section of a search: server results, loading more as the last row appears.
struct PoemSearchSection: View {
    let viewModel: PoemSearchViewModel

    var body: some View {
        Section {
            ForEach(Array(viewModel.poems.enumerated()), id: \.element.id) { index, poem in
                NavigationLink(value: PoemRoute(poems: viewModel.poems, index: index)) {
                    PoemRow(title: poem.title, excerpt: poem.excerpt)
                }
                .onAppear {
                    if poem.id == viewModel.poems.last?.id {
                        Task { await viewModel.loadMore() }
                    }
                }
            }
            status
        } header: {
            Text("Poems")
        }
    }

    @ViewBuilder
    private var status: some View {
        switch viewModel.phase {
        case .idle:
            Text("Press Search to find poems")
                .foregroundStyle(.secondary)
        case .tooShort:
            Text("Type at least two letters to search poems")
                .foregroundStyle(.secondary)
        case .loading:
            progress
        case .failed:
            retryRow
        case .loaded:
            if viewModel.poems.isEmpty {
                Text("No poems found")
                    .foregroundStyle(.secondary)
            } else if viewModel.isLoadingMore {
                progress
            } else if viewModel.loadMoreFailed {
                retryRow
            }
        }
    }

    private var progress: some View {
        ProgressView("Searching")
            .frame(maxWidth: .infinity)
    }

    private var retryRow: some View {
        HStack {
            Text("Search failed")
                .foregroundStyle(.secondary)
            Spacer()
            Button("Try again") {
                viewModel.retry()
            }
        }
    }
}

extension View {
    /// Searches when the user presses Search on the keyboard, never while typing, so each
    /// search is one request. Clearing the field cancels a running search.
    func poemSearch(_ viewModel: PoemSearchViewModel, text: String) -> some View {
        onSubmit(of: .search) {
            viewModel.submit(term: text)
        }
        .onChange(of: text) { _, newText in
            if newText.isEmpty {
                viewModel.cancel()
            }
        }
    }
}

#Preview {
    if let container = PreviewContainer.shared {
        let search = AppDependencies.preview(container: container).centuryViewModel.categoryViewModel
            .makeSearchViewModel(poetId: 2, catId: 0)
        NavigationStack {
            List {
                PoemSearchSection(viewModel: search)
            }
            .font(.customBody)
            .task { await search.search(term: "عشق") }
        }
        .persianLayout()
        .modelContainer(container)
    }
}
