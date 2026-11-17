//
//  View+Layout.swift
//  Chakame
//

import SwiftUI

extension View {
    /// Lays out Persian content right to left.
    ///
    /// Apply it to screen content, not to a `NavigationStack` or `NavigationSplitView`:
    /// the navigation chrome (back button, swipe-back edge, push direction) should follow
    /// the system's direction, the way it does in every other app on the device.
    func persianLayout() -> some View {
        environment(\.layoutDirection, .rightToLeft)
    }
}
