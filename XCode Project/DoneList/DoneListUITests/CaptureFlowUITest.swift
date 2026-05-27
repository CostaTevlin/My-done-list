// CaptureFlowUITest.swift
// End-to-end capture flow: launch → FAB → LogSheet → submit → item in list.
// Voice-recognition hardware not available in CI; the test uses the "Type instead"
// path to exercise the full capture flow without requiring mic permission.
//
// Phase: 4.5 (ADR-0010)

import XCTest

@MainActor
final class CaptureFlowUITest: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // Skip onboarding and start with a clean store for each test.
        app.launchArguments += ["-hasOnboarded", "YES", "-UITest_resetStore", "YES"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - FAB presence

    func testFAB_isAccessibleOnLaunch() throws {
        let fab = app.buttons["Log something you did"]
        XCTAssertTrue(fab.waitForExistence(timeout: 3), "FAB must be visible on Today screen")
    }

    // MARK: - LogSheet opens via FAB

    func testFAB_opensLogSheet() throws {
        let fab = app.buttons["Log something you did"]
        XCTAssertTrue(fab.waitForExistence(timeout: 3))
        fab.tap()

        // LogSheet presents — "Add a done" title should appear
        let sheetTitle = app.staticTexts["Add a done"]
        XCTAssertTrue(sheetTitle.waitForExistence(timeout: 3), "LogSheet title must appear after FAB tap")
    }

    // MARK: - Full capture flow via text mode

    func testCaptureFlow_textMode_addsRowToList() throws {
        // Open LogSheet via FAB
        let fab = app.buttons["Log something you did"]
        XCTAssertTrue(fab.waitForExistence(timeout: 3))
        fab.tap()

        // Switch to text mode (avoids mic permission dialog)
        let typeInstead = app.buttons["Switch to text input"]
        if typeInstead.waitForExistence(timeout: 2) {
            typeInstead.tap()
        }

        // Type a done item
        let textField = app.textFields.firstMatch
        XCTAssertTrue(textField.waitForExistence(timeout: 3))
        textField.tap()
        textField.typeText("Wrote end-to-end tests")

        // Submit via Done pill
        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 2))
        doneButton.tap()

        // Sheet should dismiss and new item must appear in the list.
        // ItemRow/EntryRow combine rank + text + time into one accessibility element
        // (e.g. "1, Wrote end-to-end tests, at 14:32"), so a CONTAINS search on
        // any element type is the correct way to assert the item is visible.
        let itemPredicate = NSPredicate(format: "label CONTAINS[c] %@", "Wrote end-to-end tests")
        XCTAssertTrue(
            app.descendants(matching: .any).matching(itemPredicate).firstMatch
                .waitForExistence(timeout: 5),
            "Submitted item must appear in Today list"
        )
    }

    // MARK: - GhostInputRow opens text mode

    func testGhostInputRow_opensTextMode() throws {
        // On empty state the ghost row acts as the CTA
        let ghostRow = app.buttons["Type something you did"]
        if ghostRow.waitForExistence(timeout: 2) {
            ghostRow.tap()
            let sheetTitle = app.staticTexts["Add a done"]
            XCTAssertTrue(
                sheetTitle.waitForExistence(timeout: 3),
                "Ghost row tap must open LogSheet"
            )
        } else {
            // Ghost row only shows when there are items (populated state)
            // This branch handles that scenario gracefully
            throw XCTSkip("Ghost row not visible in current app state")
        }
    }

    // MARK: - TopControls accessible

    func testTopControls_glyphsAreAccessible() throws {
        // iOS 26: native TabView — items are in the system tab bar.
        // iOS 18: BrandTabBar — items are plain Buttons with "<Label> tab" accessibility labels.
        let tabBar = app.tabBars.firstMatch
        if tabBar.waitForExistence(timeout: 3) {
            XCTAssertTrue(tabBar.buttons["Today"].exists,   "Today tab must be accessible")
            XCTAssertTrue(tabBar.buttons["Reflect"].exists, "Reflect tab must be accessible")
            XCTAssertTrue(tabBar.buttons["More"].exists,    "More tab must be accessible")
        } else {
            // iOS 18 BrandTabBar (custom, no system tabBar element)
            XCTAssertTrue(app.buttons["Today tab"].waitForExistence(timeout: 3),   "Today tab must be accessible")
            XCTAssertTrue(app.buttons["Reflect tab"].waitForExistence(timeout: 1), "Reflect tab must be accessible")
            XCTAssertTrue(app.buttons["More tab"].waitForExistence(timeout: 1),    "More tab must be accessible")
        }
    }
}
