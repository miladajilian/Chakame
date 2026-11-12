//
//  PoetSearchResults.swift
//  Chakame
//

import SwiftData
import SwiftUI

/// Poets whose nickname contains `searchText`. The query is rebuilt whenever the text changes.
struct PoetSearchResults: View {
    @Query private var poets: [PoetEntity]

    init(searchText: String) {
        _poets = Query(
            filter: #Predicate<PoetEntity> { $0.nickname.localizedStandardContains(searchText) },
            sort: \PoetEntity.name,
            animation: .default
        )
    }

    var body: some View {
        ForEach(poets) { poet in
            NavigationLink(value: CategoryRoute(id: poet.rootCatId, title: poet.nickname)) {
                PoetRow(poet: poet)
            }
        }
    }
}

#Preview {
    if let container = PreviewContainer.shared {
        NavigationStack {
            List {
                PoetSearchResults(searchText: "")
            }
        }
        .modelContainer(container)
    }
}
