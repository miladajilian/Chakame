//
//  VersesView.swift
//  Chakame
//
//  Created by Milad on 2024-02-17.
//

import SwiftData
import SwiftUI

struct VersesView: View {
    @Query private var verses: [VerseEntity]

    init(poemId: Int) {
        _verses = Query(
            filter: #Predicate<VerseEntity> { $0.poemId == poemId },
            sort: \VerseEntity.vOrder
        )
    }

    var body: some View {
        List {
            ForEach(verses) { verse in
                HStack {
                    if verse.versePosition == 1 {
                        Spacer()
                    }
                    Text(verse.text)
                        .multilineTextAlignment(.leading)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(verse.versePosition == 0 ? Color.gray.opacity(0.5) : Color(UIColor.tertiarySystemBackground))
                .contextMenu {
                    Button {
                        UIPasteboard.general.string = verse.text
                    } label: {
                        Label("Copy hemistich", systemImage: "text.line.first.and.arrowtriangle.forward")
                    }
                    Button {
                        UIPasteboard.general.string = verses.map(\.text).joined(separator: "\n")
                    } label: {
                        Label("Copy all verses", systemImage: "arrow.up.and.down.text.horizontal")
                    }
                }
            }
            if verses.isEmpty {
                ProgressView("Fetching verses")
                    .frame(maxWidth: .infinity)
            }
        }
        .font(.customBody)
        .environment(\.layoutDirection, .rightToLeft)
    }
}

#Preview {
    if let container = PreviewContainer.shared {
        VersesView(poemId: PreviewContainer.poemIdWithVerses)
            .modelContainer(container)
    }
}
