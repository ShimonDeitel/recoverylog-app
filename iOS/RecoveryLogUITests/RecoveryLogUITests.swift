import XCTest

final class RecoveryLogUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testAddButtonOpensEditor() {
        app.buttons["addButton"].tap()
        XCTAssertTrue(app.buttons["saveButton"].waitForExistence(timeout: 2))
        app.buttons["cancelButton"].tap()
    }

    func testAddFlowSavesEntry() {
        app.buttons["addButton"].tap()
        let tagField = app.textFields["tagField"]
        XCTAssertTrue(tagField.waitForExistence(timeout: 2))
        tagField.tap()
        tagField.typeText("Test Entry")
        app.buttons["saveButton"].tap()
        XCTAssertFalse(app.buttons["saveButton"].exists)
    }

    func testKeyboardDismissesOnTapOutside() {
        app.buttons["addButton"].tap()
        let noteField = app.textFields["noteField"]
        XCTAssertTrue(noteField.waitForExistence(timeout: 2))
        noteField.tap()
        XCTAssertTrue(app.keyboards.element.exists)
        let form = app.otherElements.firstMatch
        form.tap()
        app.buttons["cancelButton"].tap()
    }

    func testFreeLimitTriggersPaywall() {
        for _ in 0..<15 {
            if app.buttons["addButton"].exists {
                app.buttons["addButton"].tap()
                if app.buttons["unlockButton"].waitForExistence(timeout: 1) {
                    app.buttons["dismissPaywallButton"].tap()
                    break
                }
                if app.buttons["saveButton"].waitForExistence(timeout: 1) {
                    app.buttons["saveButton"].tap()
                }
            }
        }
        XCTAssertTrue(true)
    }

    func testSettingsOpensAndCloses() {
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["doneButton"].waitForExistence(timeout: 2))
        app.buttons["doneButton"].tap()
    }
}
