//
//  CenturiesView.swift
//  Chakame
//
//  Created by Milad on 2024-01-24.
//

import SwiftData
import SwiftUI

struct CenturiesView: View {
    @State private var viewModel: CenturyViewModel
    @Query(sort: \CenturyEntity.id, animation: .default)
    private var centuries: [CenturyEntity]

    @State private var searchText = ""
    /// The poet shown in the detail column. Collapses to push navigation in compact width.
    @State private var selectedPoet: CategoryRoute?

    init(viewModel: CenturyViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedPoet) {
                if searchText.isEmpty {
                    ForEach(centuries) { century in
                        Section(header: Text(viewModel.getCenturyTitle(century: century))) {
                            ForEach(sortedPoets(of: century)) { poet in
                                NavigationLink(value: CategoryRoute(id: poet.rootCatId, title: poet.nickname)) {
                                    PoetRow(poet: poet)
                                }
                            }
                        }
                    }
                    if viewModel.isLoading, centuries.isEmpty {
                        ProgressView("Fetching Poets list")
                    }
                } else {
                    PoetSearchResults(searchText: searchText)
                }
            }
            .searchable(text: $searchText, prompt: "Search")
            .minimizedSearchToolbar()
            .task {
                if centuries.isEmpty {
                    await viewModel.fetchCenturies()
                }
            }
            .listStyle(.plain)
            .navigationTitle("Chakame")
        } detail: {
            NavigationStack {
                Group {
                    if let selectedPoet {
                        categoryView(for: selectedPoet)
                    } else {
                        ContentUnavailableView("Choose a poet", systemImage: "book")
                            .font(.customBody)
                    }
                }
                .navigationDestination(for: CategoryRoute.self) { route in
                    categoryView(for: route)
                }
                .navigationDestination(for: PoemRoute.self) { route in
                    PagePoemView(currentIndex: route.index, poems: route.poems)
                        .environment(viewModel.categoryViewModel.poemViewModel)
                }
            }
            // A new poet starts a fresh stack instead of keeping the previous poet's screens.
            .id(selectedPoet)
        }
    }

    private func categoryView(for route: CategoryRoute) -> some View {
        CategoryView(viewModel: viewModel.categoryViewModel, parentCatId: route.id)
            .navigationTitle(route.title)
    }

    private func sortedPoets(of century: CenturyEntity) -> [PoetEntity] {
        century.poets.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

}

#Preview {
    if let container = PreviewContainer.shared {
        CenturiesView(viewModel: AppDependencies.preview(container: container).centuryViewModel)
            .modelContainer(container)
    }
}
