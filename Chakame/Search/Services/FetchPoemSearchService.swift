//
//  FetchPoemSearchService.swift
//  Chakame
//

import Foundation

struct FetchPoemSearchService {
    private let requestManager: RequestManagerProtocol

    init(requestManager: RequestManagerProtocol) {
        self.requestManager = requestManager
    }
}

extension FetchPoemSearchService: PoemSearcher {
    func search(term: String, poetId: Int, catId: Int, page: Int, pageSize: Int) async throws -> [PoemSearchResult] {
        let request = ChakameRequest.searchPoems(
            term: term, poetId: poetId, catId: catId, page: page, pageSize: pageSize
        )
        return try await requestManager.perform(request)
    }
}
