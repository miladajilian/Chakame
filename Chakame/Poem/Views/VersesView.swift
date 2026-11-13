//
//  VersesView.swift
//  Chakame
//
//  Created by Milad on 2024-02-17.
//

import SwiftData
import SwiftUI

struct VersesView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Query private var verses: [VerseEntity]

    init(poemId: Int) {
        _verses = Query(
            filter: #Predicate<VerseEntity> { $0.poemId == poemId },
            sort: \VerseEntity.vOrder
        )
    }

    var body: some View {
        List {
            if horizontalSizeClass == .regular {
                wideRows
            } else {
                compactRows
            }
            if verses.isEmpty {
                ProgressView("Fetching verses")
                    .frame(maxWidth: .infinity)
            }
        }
        .font(.customBody)
    }

    /// One hemistich per row; the left hemistich of a couplet sits at the far edge.
    private var compactRows: some View {
        ForEach(verses) { verse in
            HStack {
                if verse.versePosition == VerseLine.leftPosition {
                    Spacer()
                }
                Text(verse.text)
                    .multilineTextAlignment(.leading)
            }
            .contextMenu { copyMenu(for: verse) }
            .listRowSeparator(.hidden)
            .listRowBackground(
                rowBackground(isShaded: verse.versePosition == VerseLine.rightPosition)
            )
        }
    }

    /// Room to spare: both hemistichs of a couplet on one row, like a printed divan.
    private var wideRows: some View {
        let lines = VerseLine.lines(from: verses)
        return ForEach(Array(lines.enumerated()), id: \.element.id) { index, line in
            Group {
                switch line {
                case let .couplet(right, left):
                    // RTL: the first hemistich is on the right.
                    HStack(alignment: .firstTextBaseline, spacing: 32) {
                        hemistich(right)
                            .frame(maxWidth: 360)
                        hemistich(left)
                            .frame(maxWidth: 360)
                    }
                case let .single(verse):
                    hemistich(verse)
                        .frame(maxWidth: 720)
                }
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .listRowSeparator(.hidden)
            .listRowBackground(rowBackground(isShaded: index.isMultiple(of: 2)))
        }
    }

    private func hemistich(_ verse: VerseEntity) -> some View {
        Text(verse.text)
            .contextMenu { copyMenu(for: verse) }
    }

    @ViewBuilder
    private func copyMenu(for verse: VerseEntity) -> some View {
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

    private func rowBackground(isShaded: Bool) -> Color {
        isShaded ? Color(uiColor: .secondarySystemBackground) : Color(uiColor: .tertiarySystemBackground)
    }
}

#Preview {
    if let container = PreviewContainer.shared {
        VersesView(poemId: PreviewContainer.poemIdWithVerses)
            .modelContainer(container)
    }
}
