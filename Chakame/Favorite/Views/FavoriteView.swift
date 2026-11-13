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

    /// The poem shown in the detail column. Collapses to push navigation in compact width.
    /// The route keeps its own copy of the list, so unfavoriting the open poem keeps it on screen.
    @State private var selected: PoemRoute?

    var body: some View {
        NavigationSplitView {
            List(selection: $selected) {
                ForEach(poems.indices, id: \.self) { index in
                    let poem = poems[index]
                    NavigationLink(
                        poem.fullTitle.isEmpty ? poem.title : poem.fullTitle,
                        value: PoemRoute(poems: poems, index: index)
                    )
                }
            }
            .overlay {
                if poems.isEmpty {
                    ContentUnavailableView(
                        "No favorites yet",
                        systemImage: "heart",
                        description: Text("Tap the heart while reading a poem to save it here.")
                    )
                }
            }
            .font(.customBody)
            .navigationTitle("Favorite")
        } detail: {
            NavigationStack {
                if let selected {
                    PagePoemView(currentIndex: selected.index, poems: selected.poems)
                        .environment(poemViewModel)
                        .id(selected)
                } else {
                    ContentUnavailableView("Choose a poem", systemImage: "book")
                        .font(.customBody)
                }
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
