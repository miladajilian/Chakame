//
//  PoemTabView.swift
//  Chakame
//
//  Created by Milad on 2024-04-11.
//

import SwiftUI

struct PagePoemView: View {
    @State var currentIndex: Int
    var poems: [PoemEntity]
    @EnvironmentObject var viewModel: PoemViewModel

    var body: some View {
        ZStack {
            VersesView(poemId: poems[currentIndex].id)
                .navigationTitle(poems[currentIndex].title ?? "")
        }
        .overlay(alignment: .bottom) {
            HStack {
                // Previous Button
                Button(action: {
                    if currentIndex > 0 {
                        currentIndex -= 1
                        viewModel.fetchVerses(poem: poems[currentIndex])
                    }
                }, label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.largeTitle)
                        .opacity(0.4)
                })
                .disabled(currentIndex == 0)
                .padding()

                Spacer() // Add spacing between buttons

                // Next Button
                Button(action: {
                    if currentIndex < poems.count - 1 {
                        currentIndex += 1
                        viewModel.fetchVerses(poem: poems[currentIndex])
                    }
                }, label: {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.largeTitle)
                        .opacity(0.4)
                })
                .disabled(currentIndex == poems.count - 1)
                .padding()
            }
        }
        .task {
            viewModel.fetchVerses(poem: poems[currentIndex])
        }
        .toolbar {
            Button {
                viewModel.toggleFavorite(poem: poems[currentIndex])
            } label: {
                Image(systemName: poems[currentIndex].isFavorite ? "heart.fill" : "heart")
            }
        }
    }
}

#Preview {
    if let poems = CoreDataHelper.getTestPoems() {
        PagePoemView(currentIndex: 1,
                     poems: poems
        )
        .environmentObject(
            PoemViewModel(
                poemFetcher: PoemFetcherMock(),
                poemStore: PoemStoreService(context: CoreDataHelper.previewContext))
        )
    } else {
        EmptyView()
    }
}
