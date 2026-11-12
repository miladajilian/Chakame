//
//  CategoryRoute.swift
//  Chakame
//

import Foundation

/// Navigation value for a category screen. Destinations are registered with
/// `navigationDestination(for:)` on each tab's `NavigationStack`.
struct CategoryRoute: Hashable {
    let id: Int
    let title: String
}
