//
//  PagePoemView.swift
//  Chakame
//
//  Created by Milad on 2024-04-11.
//

import SwiftUI

struct PagePoemView: View {
    @State var currentIndex: Int
    let poems: [PoemEntity]
    @Environment(PoemViewModel.self) private var viewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var poem: PoemEntity {
        poems[currentIndex]
    }

    var body: some View {
        VersesView(poemId: poem.id)
            .navigationTitle(poem.title)
            .navigationSubtitleIfAvailable(Text("\((currentIndex + 1).persianFormatted) of \(poems.count.persianFormatted)"))
            .task {
                viewModel.fetchVerses(poem: poem)
            }
            // Hide the bottom tab bar on phones to make room for the reader. In regular width
            // (iPad, iPhone Duo inner display) the tabs stay reachable.
            .toolbar(horizontalSizeClass == .compact ? .hidden : .automatic, for: .tabBar)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    PoemShareLink(poem: poem)
                    favoriteButton
                }
                // System bottom bar: glass on iOS 26+, a standard toolbar below.
                // The layout is RTL, so "previous" sits on the right and "next" on the left.
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("Previous poem", systemImage: "chevron.backward") {
                        show(index: currentIndex - 1)
                    }
                    .keyboardShortcut(.rightArrow, modifiers: .command)
                    .disabled(currentIndex == 0)

                    Spacer()

                    Button("Next poem", systemImage: "chevron.forward") {
                        show(index: currentIndex + 1)
                    }
                    .keyboardShortcut(.leftArrow, modifiers: .command)
                    .disabled(currentIndex == poems.count - 1)
                }
            }
    }

    private var favoriteButton: some View {
        Button {
            viewModel.toggleFavorite(poem: poem)
        } label: {
            Label("Favorite", systemImage: poem.isFavorite ? "heart.fill" : "heart")
                .symbolEffect(.bounce, value: poem.isFavorite)
        }
        .keyboardShortcut("d", modifiers: .command)
        .sensoryFeedback(.success, trigger: poem.isFavorite) { _, isFavorite in isFavorite }
    }

    private func show(index: Int) {
        guard poems.indices.contains(index) else { return }
        currentIndex = index
        viewModel.fetchVerses(poem: poems[index])
    }
}

#Preview {
    if let container = PreviewContainer.shared {
        let poems = PreviewContainer.all(PoemEntity.self)
        if !poems.isEmpty {
            NavigationStack {
                PagePoemView(currentIndex: 0, poems: poems)
            }
            .environment(AppDependencies.preview(container: container).poemViewModel)
            .environment(\.layoutDirection, .rightToLeft)
            .modelContainer(container)
        }
    }
}
