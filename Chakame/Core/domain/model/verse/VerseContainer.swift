//
//  VerseContainer.swift
//  Chakame
//
//  Created by Milad on 2024-02-18.
//

import Foundation

struct VerseContainer: Decodable {
    let verses: [Verse]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        verses = try container.decode([Verse].self)
    }
}
