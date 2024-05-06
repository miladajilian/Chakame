//
//  CentuaryContainer.swift
//  Chakame
//
//  Created by Milad on 2024-01-24.
//

import Foundation

struct CenturyContainer: Decodable {
    let centuries: [Century]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        centuries = try container.decode([Century].self)
    }
}
