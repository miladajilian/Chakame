//
//  PoemShareLink.swift
//  Chakame
//

import SwiftData
import SwiftUI

/// Shares a poem's title and verses as plain text. Disabled until the verses are stored,
/// so the toolbar doesn't shift while they load.
struct PoemShareLink: View {
    let poem: PoemEntity
    @Query private var verses: [VerseEntity]

    init(poem: PoemEntity) {
        self.poem = poem
        let poemId = poem.id
        _verses = Query(
            filter: #Predicate<VerseEntity> { $0.poemId == poemId },
            sort: \VerseEntity.vOrder
        )
    }

    var body: some View {
        ShareLink(item: shareText, subject: Text(poem.title)) {
            Label("Share poem", systemImage: "square.and.arrow.up")
        }
        .disabled(verses.isEmpty)
    }

    private var shareText: String {
        ([poem.fullTitle.isEmpty ? poem.title : poem.fullTitle, ""] + verses.map(\.text))
            .joined(separator: "\n")
    }
}
