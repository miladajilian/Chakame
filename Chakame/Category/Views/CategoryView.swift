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
    let parentCatId: Int
    @Query private var categories: [CategoryEntity]
    @Query private var poems: [PoemEntity]

    init(viewModel: CategoryViewModel, parentCatId: Int) {
        self.viewModel = viewModel
        self.parentCatId = parentCatId
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
            ForEach(categories) { category in
                NavigationLink(category.title, value: CategoryRoute(id: category.id, title: category.title))
            }
            ForEach(poems.indices, id: \.self) { index in
                NavigationLink(poems[index].title, value: PoemRoute(poems: poems, index: index))
            }
            if viewModel.isLoading, categories.isEmpty, poems.isEmpty {
                ProgressView("Fetching category list")
                    .frame(maxWidth: .infinity)
            }
        }
        .font(.customBody)
        .environment(\.layoutDirection, .rightToLeft)
        .task {
            if categories.isEmpty, poems.isEmpty {
                await viewModel.fetchCategories(parentCatId: parentCatId)
            }
        }
    }
}

#Preview {
    if let container = PreviewContainer.shared {
        NavigationStack {
            CategoryView(
                viewModel: AppDependencies.preview(container: container).centuryViewModel.categoryViewModel,
                parentCatId: Poem.mock?.parentId ?? 0
            )
        }
        .modelContainer(container)
    }
}
