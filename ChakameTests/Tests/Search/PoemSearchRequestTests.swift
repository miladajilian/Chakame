//
//  PoemSearchRequestTests.swift
//  ChakameTests
//

@testable import Chakame
import Foundation
import Testing

struct PoemSearchRequestTests {
    private func queryItems(_ request: ChakameRequest) throws -> [String: String] {
        let url = try #require(try request.createURLRequest(authToken: "").url)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        #expect(components.path == "/api/ganjoor/poems/search")
        return Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value ?? "") })
    }

    @Test func globalSearchLeavesOutPoetAndCategory() throws {
        let items = try queryItems(.searchPoems(term: "عشق", poetId: 0, catId: 24, page: 1, pageSize: 20))
        #expect(items == ["term": "عشق", "PageNumber": "1", "PageSize": "20"])
    }

    @Test func poetSearchSendsPoetAndCategory() throws {
        let items = try queryItems(.searchPoems(term: "عشق", poetId: 2, catId: 24, page: 3, pageSize: 20))
        #expect(items == ["term": "عشق", "poetId": "2", "catId": "24", "PageNumber": "3", "PageSize": "20"])
    }

    @Test func poetRootSearchLeavesOutCategory() throws {
        let items = try queryItems(.searchPoems(term: "عشق", poetId: 2, catId: 0, page: 1, pageSize: 20))
        #expect(items["poetId"] == "2")
        #expect(items["catId"] == nil)
    }

    @Test func decodesTheFieldsTheAppUses() throws {
        let json = """
        [{
          "id": 2071,
          "title": "رباعی شمارهٔ ۲۱",
          "fullTitle": "حافظ » رباعیات » رباعی شمارهٔ ۲۱",
          "urlSlug": "sh21",
          "plainText": "عشق رخ یار بر من زار مگیر\\r\\nبر خسته دلان رند خمار مگیر",
          "verses": [],
          "category": { "poet": { "id": 2, "nickname": "حافظ", "rootCatId": 9 }, "cat": { "id": 9 } }
        }]
        """
        let results = try JSONDecoder().decode([PoemSearchResult].self, from: Data(json.utf8))
        let result = try #require(results.first)

        #expect(result.excerpt == "عشق رخ یار بر من زار مگیر")
        #expect(result.poem.parentId == nil)
    }
}
