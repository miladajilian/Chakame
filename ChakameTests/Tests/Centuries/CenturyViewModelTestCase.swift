//
//  CenturyViewModelTestCase.swift
//  ChakameTests
//
//  Created by Milad on 2024-01-30.
//

import XCTest
@testable import Chakame

@MainActor
final class CenturyViewModelTestCase: XCTestCase {
    let testContext = PersistenceController.preview.container.viewContext
    var viewModel: CenturyViewModel!
    
    @MainActor
    override func setUp() {
        super.setUp()
        
        viewModel =  CenturyViewModel(
            isLoading: true,
            centuryFetcher: CenturiesFetcherMock(),
            centuryStore: CenturyStoreService(context: testContext)
        )
        
    }
    
    func testFetchCenturiesLoadingState() async {
        XCTAssertTrue(viewModel.isLoading, "the view model should be loading, but  it isn't")
        await viewModel.fetchCenturies()
        XCTAssertFalse(viewModel.isLoading, "The View model shouldn't be loading, but it is")
    }
    
    func  testGetCenturyTitle() {
        let fetchRequest = CenturyEntity.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CenturyEntity.id, ascending: true)]
        guard let results = try? testContext.fetch(fetchRequest),
              let first = results.first else { return }
        let title = viewModel.getCenturyTitle(century: first)
        XCTAssertEqual(title, String(localized: "Popular Poets"))
    }
}

struct EmptyResponseCentuiresFetcherMock: CenturiesFetcher {
    func fetchCenturies() async -> [Chakame.Century] {
        return []
    }
}
