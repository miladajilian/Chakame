//
//  CategoryView.swift
//  Chakame
//
//  Created by Milad on 2024-01-30.
//

import SwiftUI

struct CategoryView: View {
    @ObservedObject var viewModel: CategoryViewModel
    @FetchRequest var categories: FetchedResults<CategoryEntity>
    @FetchRequest var poems: FetchedResults<PoemEntity>
    
    var body: some View {
        List {
            ForEach(categories) { category in
                NavigationLink(
                    category.title ?? "",
                    destination: categoryDestinationView(category: category)
                )
            }
            ForEach(poems.indices, id: \.self) { index in
                NavigationLink(
                    poems[index].title ?? "",
                    destination: poemDestinationView(index: index)
                )
            }
            if viewModel.isLoading && categories.isEmpty && poems.isEmpty {
                ProgressView("Fetching category list")
                    .frame(maxWidth: .infinity)
            }
        }
        .font(.customBody)
        .environment(\.layoutDirection, .rightToLeft)
        .task {
            if categories.isEmpty && poems.isEmpty {
                await viewModel.fetchCategories()
            }
        }
    }
    
    func categoryDestinationView(category: CategoryEntity) -> some View {
        CategoryView(
            viewModel: CategoryViewModel(
                parentCatId: Int(category.id),
                categoriesFetcher: viewModel.categoriesFetcher,
                categoryStore: viewModel.categoryStore)
            )
        .navigationTitle(category.title ?? "")
    }
    
    func poemDestinationView(index: Int) -> some View {
        PagePoemView(currentIndex: index, poems: Array(poems))
    }
}

extension CategoryView {
    init(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        
        _categories = FetchRequest(
            fetchRequest: viewModel.getCategoryFetchRequest()
        )
        _poems = FetchRequest(
            fetchRequest: viewModel.getPoemFetchRequest()
        )
    }
}

#Preview {
    CategoryView(
        viewModel: CategoryViewModel(
            parentCatId: 32,
            categoriesFetcher: CategoriesFetcherMock(),
            categoryStore: CategoryStoreService(context: CoreDataHelper.previewContext)))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}


