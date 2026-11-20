//
//  CategoryView.swift
//  Chakame
//
//  Created by Milad on 2024-01-30.
//

import SwiftData
import SwiftUI

struct CategoryView: View {
    let viewModel: CategoryViewModel
    let route: CategoryRoute
    @Query private var categories: [CategoryEntity]
    @Query private var poems: [PoemEntity]

    @State private var searchText = ""
    /// Server search over this category's poems (all of the poet's at the poet's root).
    @State private var poemSearch: PoemSearchViewModel

    private var parentCatId: Int {
        route.id
    }

    init(viewModel: CategoryViewModel, route: CategoryRoute) {
        self.viewModel = viewModel
        self.route = route
        let parentCatId = route.id
        _poemSearch = State(
            initialValue: viewModel.makeSearchViewModel(poetId: route.poetId, catId: route.searchCatId)
        )
        _categories = Query(
            filter: #Predicate<CategoryEntity> { $0.parentId == parentCatId },
            sort: \CategoryEntity.title
        )
        _poems = Query(
            filter: #Predicate<PoemEntity> { $0.parentId == parentCatId },
            sort: \PoemEntity.id
        )
    }

    var body: some View {
        List {
            if searchText.isEmpty {
                contents
            } else {
                PoemSearchSection(viewModel: poemSearch)
            }
        }
        .font(.customBody)
        .searchable(text: $searchText, prompt: Text("Search in \(route.title)"))
        .poemSearch(poemSearch, text: searchText)
        .navigationSubtitleIfAvailable(subtitle)
        .task {
            if categories.isEmpty, poems.isEmpty || isMissingExcerpts {
                await viewModel.fetchCategories(parentCatId: parentCatId)
            }
        }
    }

    @ViewBuilder
    private var contents: some View {
        ForEach(categories) { category in
            NavigationLink(
                category.title,
                value: CategoryRoute(id: category.id, title: category.title, poetId: route.poetId)
            )
        }
        ForEach(poems.indices, id: \.self) { index in
            NavigationLink(value: PoemRoute(poems: poems, index: index)) {
                PoemRow(title: poems[index].title, excerpt: poems[index].excerpt)
            }
        }
        if viewModel.isLoading, categories.isEmpty, poems.isEmpty {
            ProgressView("Fetching category list")
                .frame(maxWidth: .infinity)
        }
    }

    /// Poems cached before `excerpt` existed have none, so fetch once more to fill them in.
    private var isMissingExcerpts: Bool {
        !poems.isEmpty && poems.allSatisfy(\.excerpt.isEmpty)
    }

    /// e.g. "12 poems". Hidden while loading or for categories that hold only subcategories.
    private var subtitle: Text {
        poems.isEmpty ? Text(verbatim: "") : Text("\(poems.count.persianFormatted) poems")
    }
}

#Preview {
    if let container = PreviewContainer.shared {
        NavigationStack {
            CategoryView(
                viewModel: AppDependencies.preview(container: container).centuryViewModel.categoryViewModel,
                route: CategoryRoute(id: Poem.mock?.parentId ?? 0, title: "غزلیات", poetId: 2)
            )
        }
        .modelContainer(container)
    }
}
