//
//  PoetContainer.swift
//  Chakame
//
//  Created by Milad on 2024-01-24.
//

import Foundation

struct PoetContainer: Decodable {
    let poets: [Poet]
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        poets = try container.decode([Poet].self)
    }
}
