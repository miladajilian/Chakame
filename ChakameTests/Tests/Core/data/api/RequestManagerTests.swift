//
//  RequestManagerTests.swift
//  ChakameTests
//
//  Created by Milad on 2024-01-24.
//

import XCTest
@testable import Chakame

class RequestManagerTests: XCTestCase {
    private var requestManager: RequestManagerProtocol?
    
    override func setUp() {
        super.setUp()
        guard let userDefaults = UserDefaults(suiteName: #file) else {
            return
        }
        userDefaults.removePersistentDomain(forName: #file)
        requestManager = RequestManager(apiManager: APIManagerMock())
    }
    
    func testFetchCenteries() async throws {
        guard let centeriesContainer: CenturyContainer = try await requestManager?.perform(PoetRequestMock.getCenturies) else {
            XCTFail("Didn't get data from the request manager")
            return
        }
        
        let centeries = centeriesContainer.centuries
        
        let first = centeries.first
        let last = centeries.last
        
        XCTAssertEqual(first?.id, 0)
        XCTAssertEqual(first?.name, "")
        XCTAssertEqual(first?.halfCenturyOrder, 0)
        XCTAssertEqual(first?.startYear, 0)
        XCTAssertEqual(first?.endYear, 0)
        XCTAssertEqual(first?.showInTimeLine, false)
        
        XCTAssertEqual(last?.id, 1785)
        XCTAssertEqual(last?.name, "قرن چهارم")
        XCTAssertEqual(last?.halfCenturyOrder, 2)
        XCTAssertEqual(last?.startYear, 300)
        XCTAssertEqual(last?.endYear, 399)
        XCTAssertEqual(last?.showInTimeLine, true)
    }
    
    func testFetchCategories() async throws {
        guard let categoriesContainer: CategoryContainer = try await requestManager?.perform(CategoryRequestMock.getCategories) else {
            XCTFail("Didn't get data from the request manager")
            return
        }
        
        let categories = categoriesContainer.categories
        let poems = categoriesContainer.poems
        
        let firstPoem = poems.first
        let firstCategory = categories.first
        
        XCTAssertEqual(firstPoem?.id, 10059)
        XCTAssertEqual(firstPoem?.title, "مثنوی (الا ای آهوی وحشی)")
        XCTAssertEqual(firstPoem?.urlSlug, "masnavi")
        
        XCTAssertEqual(firstCategory?.id, 24)
        XCTAssertEqual(firstCategory?.title, "غزلیات")
        XCTAssertEqual(firstCategory?.urlSlug, "ghazal")
        XCTAssertEqual(firstCategory?.fullUrl, "/hafez/ghazal")
    }
}
