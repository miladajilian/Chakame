//
//  StoreUnavailableView.swift
//  Chakame
//

import SwiftUI

/// Shown when the SwiftData store can't be opened.
struct StoreUnavailableView: View {
    var body: some View {
        ContentUnavailableView("Unable to open the library", systemImage: "exclamationmark.triangle")
            .font(.customBody)
            .environment(\.layoutDirection, .rightToLeft)
    }
}

#Preview {
    StoreUnavailableView()
}
