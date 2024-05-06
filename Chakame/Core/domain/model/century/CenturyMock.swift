//
//  CenturyMock.swift
//  Chakame
//
//  Created by Milad on 2024-01-24.
//

import Foundation

//private struct CenturyMock: Codable {
//    let centuries: [Century]
//}

private func loadCenturies() -> [Century] {
    guard let url = Bundle.main.url(forResource: "CenturiesMock", withExtension: "json"),
          let data = try? Data(contentsOf: url) else { return [] }
    let decoder = JSONDecoder()
    
//    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let jsonMock = try? decoder.decode(CenturyContainer.self, from: data)
    return jsonMock?.centuries ?? []
}

extension Century {
    static let mock = loadCenturies()
}
