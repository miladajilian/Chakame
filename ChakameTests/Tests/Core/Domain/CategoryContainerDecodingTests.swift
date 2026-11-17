//
//  CategoryContainerDecodingTests.swift
//  ChakameTests
//

@testable import Chakame
import Foundation
import Testing

struct CategoryContainerDecodingTests {
    @Test func poemsKeepTheirExcerptAndParent() throws {
        let json = """
        {
          "cat": {
            "id": 24,
            "title": "غزلیات",
            "poems": [
              { "id": 2130, "title": "غزل شمارهٔ ۱", "urlSlug": "sh1", "excerpt": "اَلا یا اَیُّهَا السّاقی", "mainSections": null },
              { "id": 2131, "title": "غزل شمارهٔ ۲", "urlSlug": "sh2" }
            ]
          }
        }
        """
        let container = try JSONDecoder().decode(CategoryContainer.self, from: Data(json.utf8))

        #expect(container.poems.map(\.excerpt) == ["اَلا یا اَیُّهَا السّاقی", nil])
        #expect(container.poems.allSatisfy { $0.parentId == 24 })
    }
}
