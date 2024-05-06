//
//  Poem.swift
//  Chakame
//
//  Created by Milad on 2024-01-31.
//

import Foundation

struct Poem: Codable {
    var id: Int
    var parentId: Int?
    var title: String?
    var urlSlug: String?
    var fullTitle: String?
    var verses: [Verse]?
    var next: NeighborPoem?
    var previous: NeighborPoem?
}

struct NeighborPoem: Codable {
    var id: Int
}

// MARK: - Identifiable
extension Poem: Identifiable {
}
