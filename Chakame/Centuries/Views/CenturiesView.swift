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

    init(viewModel: CenturyViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List {
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
            .task {
                if centuries.isEmpty {
                    await viewModel.fetchCenturies()
                }
            }
            .listStyle(.plain)
            .navigationTitle("Chakame")
            .navigationDestination(for: CategoryRoute.self) { route in
                CategoryView(viewModel: viewModel.categoryViewModel, parentCatId: route.id)
                    .navigationTitle(route.title)
            }
            .navigationDestination(for: PoemRoute.self) { route in
                PagePoemView(currentIndex: route.index, poems: route.poems)
                    .environment(viewModel.categoryViewModel.poemViewModel)
            }
            .environment(\.layoutDirection, .rightToLeft)
        }
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
