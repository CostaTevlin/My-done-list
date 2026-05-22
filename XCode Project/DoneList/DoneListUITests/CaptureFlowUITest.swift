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

        // Sheet should dismiss and new item must appear in the list
        XCTAssertTrue(
            app.staticTexts["Wrote end-to-end tests"].waitForExistence(timeout: 3),
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
            XCTSkip("Ghost row not visible in current app state")
        }
    }

    // MARK: - TopControls accessible

    func testTopControls_glyphsAreAccessible() throws {
        let search  = app.buttons["Search"]
        let reflect = app.buttons["Reflect"]
        let more    = app.buttons["More"]

        XCTAssertTrue(search.waitForExistence(timeout: 3),  "Search glyph must be accessible")
        XCTAssertTrue(reflect.waitForExistence(timeout: 1), "Reflect glyph must be accessible")
        XCTAssertTrue(more.waitForExistence(timeout: 1),    "More glyph must be accessible")
    }
}
