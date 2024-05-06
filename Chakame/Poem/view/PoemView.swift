//
//  PoemView.swift
//  Chakame
//
//  Created by Milad on 2024-02-17.
//

import SwiftUI

struct PoemView: View {
    @ObservedObject var viewModel: PoemViewModel
    @FetchRequest var verses: FetchedResults<VerseEntity>

    var body: some View {
        List {
            ForEach(verses) { verse in
                HStack {
                    if verse.versePosition == 1 {
                        Spacer()
                    }
                    Text(verse.text ?? "")
                        .multilineTextAlignment(.leading)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(verse.versePosition == 0 ? Color.gray.opacity(0.5) : Color(UIColor.tertiarySystemBackground))
            }
            if viewModel.isLoading && verses.isEmpty {
                ProgressView("Fetching verses")
                    .frame(maxWidth: .infinity)
            }
        }
        .font(.customBody)
        .environment(\.layoutDirection, .rightToLeft)
        .toolbar {
            Button {
                viewModel.toggleFavorite()
            } label: {
                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
            }
        }
        .font(.customBody)
        .task {
            if verses.isEmpty {
                await viewModel.fetchVerses()
            }
        }
    }
}

extension PoemView {
    init(viewModel: PoemViewModel) {
        self.viewModel = viewModel
        
        _verses = FetchRequest(
            fetchRequest: viewModel.getVerseFetchRequest()
        )
    }
}

#Preview {
    if let poem = CoreDataHelper.getTestPoem() {
        PoemView(
            viewModel: PoemViewModel(
                poem: poem,
                poemFetcher: PoemFetcherMock(),
                poemStore: PoemStoreService(context: CoreDataHelper.previewContext)))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    } else {
        EmptyView()
    }
}
