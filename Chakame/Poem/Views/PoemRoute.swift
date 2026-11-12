//
//  PoemRoute.swift
//  Chakame
//

import Foundation

/// Navigation value for the paged poem reader: the list to page through and where to start.
struct PoemRoute: Hashable {
    let poems: [PoemEntity]
    let index: Int
}
