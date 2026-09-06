import XCTest

final class TodoCounterUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAddsCompletesAndCountsThroughRegistryStyledControls() throws {
        let app = XCUIApplication()
        app.launch()

        let field = app.textFields["New task"]
        XCTAssertTrue(field.waitForExistence(timeout: 5), "The registry-styled input must be reachable by its label.")
        field.tap()
        // The return key submits through onSubmit and dismisses the keyboard.
        field.typeText("Buy milk\n")
        XCTAssertTrue(app.staticTexts["Buy milk"].waitForExistence(timeout: 2), "Adding must render the todo.")
        XCTAssertEqual(field.value as? String, "Add a task", "Adding must clear the draft back to its placeholder.")

        let checkbox = app.switches["Buy milk"].firstMatch
        XCTAssertTrue(checkbox.waitForExistence(timeout: 2), "The registry checkbox must expose the todo as a switch.")
        checkbox.tap()
        XCTAssertTrue(app.buttons["Clear 1 completed"].waitForExistence(timeout: 2), "Completing a todo must offer to clear it.")
        XCTAssertTrue(app.staticTexts["0 LEFT"].exists, "The customized badge must count the remaining tasks in uppercase.")

        app.tabBars.buttons["Counter"].tap()
        let increment = app.buttons["Increment"]
        XCTAssertTrue(increment.waitForExistence(timeout: 5))
        increment.tap()
        increment.tap()
        XCTAssertTrue(app.staticTexts["Count 2"].waitForExistence(timeout: 2), "Two increments must show 2.")
        XCTAssertTrue(app.staticTexts["PRIME"].exists, "2 is prime, and the badge says so in uppercase.")
        app.buttons["Reset"].tap()
        XCTAssertTrue(app.staticTexts["Count 0"].waitForExistence(timeout: 2), "Reset must return to 0.")
    }
}
