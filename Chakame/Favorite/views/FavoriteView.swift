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
                ForEach(poems.indices, id: \.self) { index in
                    let title = ((poems[index].fullTitle?.isEmpty) != nil) ? poems[index].fullTitle : poems[index].title ?? ""
                    NavigationLink(
                        title ?? "",
                        destination: poemDestinationView(index: index)
                    )
                }
            }
            .font(.customBody)
            .environment(\.layoutDirection, .rightToLeft)
            .navigationTitle("Favorite")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    func poemDestinationView(index: Int) -> some View {
        PagePoemView(currentIndex: index, poems: Array(poems))
            .environmentObject(PoemViewModel())
    }
}

#Preview {
    FavoriteView()
}
