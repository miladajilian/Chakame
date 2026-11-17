//
//  PoemRow.swift
//  Chakame
//

import SwiftUI

/// A poem's title with its first line underneath, like Ganjoor's poem lists.
struct PoemRow: View {
    let title: String
    let excerpt: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: title)
            if !excerpt.isEmpty {
                Text(verbatim: excerpt)
                    .font(.customSubheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

#Preview {
    List {
        PoemRow(title: "غزل شمارهٔ ۱", excerpt: "اَلا یا اَیُّهَا السّاقی اَدِرْ کَأسَاً و ناوِلْها")
        PoemRow(title: "غزل شمارهٔ ۲", excerpt: "")
    }
    .font(.customBody)
}
