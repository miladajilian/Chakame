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
        // Keep this the plain `ShareLink(item:)` form so the share sheet gets the String itself.
        // Adding `subject:` or `preview:` makes SwiftUI wrap it in an opaque item provider:
        // the sheet shows a blank preview, Copy can disappear, and some targets get no text.
        ShareLink(item: shareText) {
            Label("Share poem", systemImage: "square.and.arrow.up")
        }
        .disabled(verses.isEmpty)
    }

    private var title: String {
        poem.fullTitle.isEmpty ? poem.title : poem.fullTitle
    }

    private var shareText: String {
        ([title, ""] + verses.map(\.text)).joined(separator: "\n")
    }
}
