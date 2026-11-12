//
//  View+LiquidGlass.swift
//  Chakame
//

import SwiftUI

/// Shims for iOS 26+ Liquid Glass behaviors. On older iOS they do nothing,
/// so feature code can call them without `#available` checks.
extension View {
    /// Shrinks the floating tab bar while content scrolls down (iOS 26+).
    @ViewBuilder
    func minimizeTabBarOnScroll() -> some View {
        if #available(iOS 26.0, *) {
            tabBarMinimizeBehavior(.onScrollDown)
        } else {
            self
        }
    }

    /// Shows a subtitle under the navigation title (iOS 26+ on iPhone).
    @ViewBuilder
    func navigationSubtitleIfAvailable(_ subtitle: Text) -> some View {
        if #available(iOS 26.0, *) {
            navigationSubtitle(subtitle)
        } else {
            self
        }
    }

    /// Folds the search field into a compact glass toolbar button (iOS 26+).
    @ViewBuilder
    func minimizedSearchToolbar() -> some View {
        if #available(iOS 26.0, *) {
            searchToolbarBehavior(.minimize)
        } else {
            self
        }
    }
}
