//
//  PoetMock.swift
//  Chakame
//
//  Created by Milad on 2024-01-24.
//

import Foundation

private func loadPoets() -> [Poet] {
    guard let url = Bundle.main.url(forResource: "PoetsMock", withExtension: "json"),
          let data = try? Data(contentsOf: url) else { return [] }
    let decoder = JSONDecoder()
    
//    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let jsonMock = try? decoder.decode(PoetContainer.self, from: data)
    return jsonMock?.poets ?? []
}

extension Poet {
    static let listMock = loadPoets()
    static let mock = loadPoets().first ?? Poet(id: 0, name: nil, description: nil, fullUrl: nil, rootCatId: nil, nickname: nil, published: nil, imageUrl: nil, birthYearInLHijri: nil, validBirthDate: nil, deathYearInLHijri: nil, validDeathDate: nil, pinOrder: nil, birthPlace: nil, birthPlaceLatitude: nil, birthPlaceLongitude: nil, deathPlaceLatitude: nil, deathPlaceLongitude: nil, deathPlace: nil)
}
