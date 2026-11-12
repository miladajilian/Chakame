//
//  Verse.swift
//  Chakame
//
//  Created by Milad on 2024-02-18.
//

import Foundation

struct Verse: Codable {
    var id: Int
    var text: String?
    var vOrder: Int?
    var coupletIndex: Int?
    var versePosition: Int16?
}

// MARK: - Identifiable
extension Verse: Identifiable {
}
