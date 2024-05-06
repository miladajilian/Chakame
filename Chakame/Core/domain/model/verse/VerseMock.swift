//
//  VerseMock.swift
//  Chakame
//
//  Created by Milad on 2024-02-18.
//

import Foundation

private func loadVerses() -> [Verse] {
    guard let url = Bundle.main.url(forResource: "VersesMock", withExtension: "json"),
          let data = try? Data(contentsOf: url) else { return [] }
    let decoder = JSONDecoder()
    
//    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let jsonMock = try? decoder.decode(VerseContainer.self, from: data)
    return jsonMock?.verses ?? []
}

extension Verse {
    static let mock = loadVerses()
}
