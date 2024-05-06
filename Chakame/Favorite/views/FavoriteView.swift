//
//  FavoriteView.swift
//  Chakame
//
//  Created by Milad on 2024-02-19.
//

import SwiftUI

struct FavoriteView: View {
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \PoemEntity.id, ascending: true)
        ],
        predicate: NSPredicate(format: "isFavorite = %d", true),
        animation: .default
    )
    var poems: FetchedResults<PoemEntity>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(poems) { poem in
                    NavigationLink(
                        poem.fullTitle ?? "",
                        destination: poemDestinationView(poem: poem)
                    )
                }
                
            }
            .font(.customBody)
            .environment(\.layoutDirection, .rightToLeft)
            .navigationTitle("Favorite")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    func poemDestinationView(poem: PoemEntity) -> some View {
        PoemView(
            viewModel: PoemViewModel(
                poem: poem,
                poemFetcher: FetchPoemService(requestManager: RequestManager.shared),
                poemStore: PoemStoreService(context: PersistenceController.shared.container.newBackgroundContext()))
            )
        .navigationTitle(poem.title ?? "")
    }
}

#Preview {
    FavoriteView()
}
