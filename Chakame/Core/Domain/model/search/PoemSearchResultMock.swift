//
//  PoemSearchResultMock.swift
//  Chakame
//

import Foundation

private func loadSearchResults() -> [PoemSearchResult] {
    guard let url = Bundle.main.url(forResource: "PoemSearchMock", withExtension: "json"),
          let data = try? Data(contentsOf: url) else {
        return []
    }
    return (try? JSONDecoder().decode([PoemSearchResult].self, from: data)) ?? []
}

extension PoemSearchResult {
    static let mock = loadSearchResults()
}
