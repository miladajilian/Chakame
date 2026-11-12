//
//  CenturiesView.swift
//  Chakame
//
//  Created by Milad on 2024-01-24.
//

import SwiftUI

struct CenturiesView: View {
    @ObservedObject var viewModel = CenturyViewModel()
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \CenturyEntity.id, ascending: true)
        ],
        animation: .default
    )
    var centuries: FetchedResults<CenturyEntity>

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \PoetEntity.name, ascending: true)
        ], animation: .default
    )
    var poets: FetchedResults<PoetEntity>

    @State private var searchText = ""

    var body: some View {
        NavigationView {
            List {
                if searchText.isEmpty {
                    ForEach(centuries) { century in
                        Section(header: Text(viewModel.getCenturyTitle(century: century))) {
                            if let poets = century.poets?.allObjects as? [PoetEntity] {
                                ForEach(poets) { poet in
                                    NavigationLink(destination: destinationView(poet: poet)) {
                                        PoetRow(poet: poet)
                                    }
                                }
                            }
                        }
                    }
                    if viewModel.isLoading && centuries.isEmpty {
                        ProgressView("Fetching Poets list")
                    }
                } else {
                    ForEach(poets) { poet in
                        NavigationLink(destination: destinationView(poet: poet)) {
                            PoetRow(poet: poet)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search")
            .onChange(of: searchText, perform: { _ in
                searchByName()
            })
            .task {
                if centuries.isEmpty {
                    await viewModel.fetchCenturies()
                }
            }
            .listStyle(.plain)
            .navigationTitle("Chakame")
            .environment(\.layoutDirection, .rightToLeft)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    func destinationView(poet: PoetEntity) -> some View {
        CategoryView(
            viewModel: self.viewModel.categoryViewModel,
            parentCatId: Int(poet.rootCatId)
        )
        .navigationTitle(poet.nickname ?? "")
    }

    private func searchByName() {
        let predicate: NSPredicate?
        if !searchText.isEmpty {
            let nickNamePredicate = NSPredicate(format: "nickname CONTAINS %@", searchText)
            predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [nickNamePredicate])
        } else {
            predicate = nil
        }
        poets.nsPredicate = predicate
    }
}

#Preview {
    CenturiesView(
        viewModel: CenturyViewModel(
            centuryFetcher: CenturiesFetcherMock(),
            centuryStore: CenturyStoreService(context: CoreDataHelper.previewContext)))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
