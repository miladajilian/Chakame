//
//  PoemView.swift
//  Chakame
//
//  Created by Milad on 2024-02-17.
//

import SwiftUI
import CoreData

struct VersesView: View {
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
                .contextMenu {
                    Button {
                        UIPasteboard.general.string = verse.text
                    } label: {
                        Label("Copy hemistich", systemImage: "text.line.first.and.arrowtriangle.forward")
                    }
                    Button {
                        UIPasteboard.general.string = verses.compactMap { $0.text }.joined(separator: "\n")
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
        .font(.customBody)
    }
}

extension VersesView {
    init(poemId: Int32) {
        let verseRequest: NSFetchRequest<VerseEntity> = VerseEntity.fetchRequest()
        verseRequest.predicate = NSPredicate(
            format: "poemId = \(poemId)"
        )
        verseRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \VerseEntity.vOrder, ascending: true)
        ]
        _verses = FetchRequest(
            fetchRequest: verseRequest
        )
    }
}

#Preview {
    VersesView(poemId: 10060)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
