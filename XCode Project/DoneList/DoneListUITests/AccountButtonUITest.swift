// AccountButtonUITest.swift
// UI tests for the Account navbar button on the Today screen.
// Verifies: button is reachable, tapping opens SettingsView sheet,
// and the sheet dismisses correctly.
//
// Selector note (per feedback_uitest-tabs memory):
//   iOS 26 native TabView: app.tabBars.buttons["Today"]
//   iOS 18 BrandTabBar:    app.buttons["Today tab"]
// The Account button is a plain SwiftUI Button — same selector on both.
//
// Phase: R4 — D3 composite navbar (ADR-0010, ADR-0005)

import XCTest

@MainActor
final class AccountButtonUITest: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["-hasOnboarded", "YES", "-UITest_resetStore", "YES"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Account button visible on Today

    func testAccountButton_isVisibleOnTodayTab() throws {
        // Ensure we're on the Today tab (app launches there by default)
        let accountButton = app.buttons["Account"]
        XCTAssertTrue(
            accountButton.waitForExistence(timeout: 5),
            "Account button must be visible on the Today screen toolbar"
        )
    }

    // MARK: - Account button opens Settings sheet

    func testAccountButton_opensSettingsSheet() throws {
        let accountButton = app.buttons["Account"]
        XCTAssertTrue(accountButton.waitForExistence(timeout: 5))
        accountButton.tap()

        // SettingsView has .navigationTitle("Account") — look for the nav bar title text.
        // Use the navigation bar element as a stable identifier; it always reads "Account"
        // when SettingsView is the root of its NavigationStack.
        let settingsTitle = app.navigationBars["Account"]
        XCTAssertTrue(
            settingsTitle.waitForExistence(timeout: 3),
            "Settings sheet must present with 'Account' navigation bar after tapping Account button"
        )
    }

    // MARK: - Settings sheet dismisses via swipe-down

    func testAccountButton_settingsSheet_dismissesOnSwipeDown() throws {
        let accountButton = app.buttons["Account"]
        XCTAssertTrue(accountButton.waitForExistence(timeout: 5))
        accountButton.tap()

        let settingsTitle = app.navigationBars["Account"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 3))

        // Swipe down to dismiss the sheet
        app.swipeDown()

        // After dismiss, the Account button should be visible again
        XCTAssertTrue(
            accountButton.waitForExistence(timeout: 3),
            "Account button must be visible again after dismissing Settings sheet"
        )
    }
}
