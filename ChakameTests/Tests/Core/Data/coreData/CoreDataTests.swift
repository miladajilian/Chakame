//
//  CoreDataTests.swift
//  ChakameTests
//
//  Created by Milad on 2024-01-25.
//

import XCTest
@testable import Chakame
import CoreData

class CoreDataTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }
    
    func testToManagedObject() throws {
        let previewContext = PersistenceController.preview.container.viewContext
        let fetchRequest = CenturyEntity.fetchRequest()
        fetchRequest.fetchLimit = 3
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CenturyEntity.id, ascending: true)]
        guard let results = try? previewContext.fetch(fetchRequest),
              let first = results.first else { return }
        
        XCTAssert(first.id == 0, """
          Century id did not match, was expecting 0, got
          \(String(describing: first.id))
        """)
        XCTAssert(first.name == "", """
          Century name did not match, was expecting empty, got
          \(String(describing: first.name))
        """)
        XCTAssert(first.startYear == 0, """
          Century startYear did not match, was expecting 0, got
          \(first.startYear)
        """)
//        
//        XCTAssert(last.id == 1785, """
//          Century id did not match, was expecting 1785, got
//          \(String(describing: first.id))
//        """)
//        XCTAssert(last.name == "قرن چهارم", """
//          Century name did not match, was expecting "قرن چهارم", got
//          \(String(describing: first.name))
//        """)
//        XCTAssert(last.startYear == 300, """
//          Century startYear did not match, was expecting 300, got
//          \(first.startYear)
//        """)
    }
    
    func testDeleteManagedObject() throws {
        let previewContext = PersistenceController.preview.container.viewContext
        
        let fetchRequest = CenturyEntity.fetchRequest()
        guard let results = try? previewContext.fetch(fetchRequest),
              let first = results.first else { return }
        
        let expectedResult = results.count - 1
        previewContext.delete(first)
        
        guard let resultsAfterDeletion = try? previewContext.fetch(fetchRequest)
        else { return }
        
        XCTAssertEqual(expectedResult, resultsAfterDeletion.count, """
        The number of results was expected to be \(expectedResult) after deletion, was \(results.count)
      """)
    }
}
