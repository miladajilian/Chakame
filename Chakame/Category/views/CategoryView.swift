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
    let parentCatId: Int
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
                await viewModel.fetchCategories(parentCatId: parentCatId)
            }
        }
    }
    
    func categoryDestinationView(category: CategoryEntity) -> some View {
        CategoryView(
            viewModel: viewModel,
            parentCatId: Int(category.id)
        )
        .navigationTitle(category.title ?? "")
    }
    
    func poemDestinationView(index: Int) -> some View {
        PagePoemView(currentIndex: index, poems: Array(poems))
            .environmentObject(viewModel.poemViewModel)
    }
}

extension CategoryView {
    init(viewModel: CategoryViewModel, parentCatId: Int) {
        self.viewModel = viewModel
        self.parentCatId = parentCatId
        
        _categories = FetchRequest(
            fetchRequest: viewModel.getCategoryFetchRequest(parentCatId: parentCatId)
        )
        _poems = FetchRequest(
            fetchRequest: viewModel.getPoemFetchRequest(parentCatId: parentCatId)
        )
    }
}

#Preview {
    CategoryView(
        viewModel: CategoryViewModel(
            categoriesFetcher: CategoriesFetcherMock(),
            categoryStore: CategoryStoreService(context: CoreDataHelper.previewContext)),
        parentCatId: 32
    )
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}


