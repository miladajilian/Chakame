//
//  PoemSearcherMock.swift
//  Chakame
//

import Foundation

struct PoemSearcherMock: PoemSearcher {
    func search(term: String, poetId: Int, catId: Int, page: Int, pageSize: Int) async throws -> [PoemSearchResult] {
        page == 1 ? PoemSearchResult.mock : []
    }
}
