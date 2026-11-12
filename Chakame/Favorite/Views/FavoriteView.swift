//
//  FavoriteView.swift
//  Chakame
//
//  Created by Milad on 2024-02-19.
//

import SwiftData
import SwiftUI

struct FavoriteView: View {
    let poemViewModel: PoemViewModel
    @Query(
        filter: #Predicate<PoemEntity> { $0.isFavorite },
        sort: \PoemEntity.id,
        animation: .default
    )
    private var poems: [PoemEntity]

    var body: some View {
        NavigationStack {
            List {
                ForEach(poems.indices, id: \.self) { index in
                    let poem = poems[index]
                    NavigationLink(
                        poem.fullTitle.isEmpty ? poem.title : poem.fullTitle,
                        value: PoemRoute(poems: poems, index: index)
                    )
                }
            }
            .font(.customBody)
            .environment(\.layoutDirection, .rightToLeft)
            .navigationTitle("Favorite")
            .navigationDestination(for: PoemRoute.self) { route in
                PagePoemView(currentIndex: route.index, poems: route.poems)
                    .environment(poemViewModel)
            }
        }
    }
}

#Preview {
    if let container = PreviewContainer.shared {
        FavoriteView(poemViewModel: AppDependencies.preview(container: container).poemViewModel)
            .modelContainer(container)
    }
}
