//
//  ChakameUITests.swift
//  ChakameUITests
//

import XCTest

final class ChakameUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Smoke test: the app launches and shows its three main tabs.
    func testLaunchShowsMainTabs() throws {
        let app = XCUIApplication()
        app.launch()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10))
        // Labels are localized (Persian), so assert on the count: Home, Favorite, Setting.
        XCTAssertEqual(tabBar.buttons.count, 3)
    }
}
