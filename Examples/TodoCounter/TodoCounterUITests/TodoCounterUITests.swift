import XCTest

/// The same flow on all three UI layers proves feature parity; the labels differ only where
/// the design differs (the registry and handmade badges are uppercase, the plain text is not).
final class TodoCounterUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testRegistryLayerAddsCompletesAndCounts() throws {
        try drive(variant: "registry", remaining: "0 LEFT", prime: "PRIME")
    }

    @MainActor
    func testPlainLayerAddsCompletesAndCounts() throws {
        try drive(variant: "plain", remaining: "0 left", prime: "Prime")
    }

    @MainActor
    func testHandmadeLayerAddsCompletesAndCounts() throws {
        try drive(variant: "handmade", remaining: "0 LEFT", prime: "PRIME")
    }

    @MainActor
    private func drive(variant: String, remaining: String, prime: String) throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui", variant]
        app.launch()

        let field = app.textFields["New task"]
        XCTAssertTrue(field.waitForExistence(timeout: 5), "The input must be reachable by its label.")
        field.tap()
        // The return key submits through onSubmit and dismisses the keyboard.
        field.typeText("Buy milk\n")
        XCTAssertTrue(app.staticTexts["Buy milk"].waitForExistence(timeout: 2), "Adding must render the todo.")
        XCTAssertEqual(field.value as? String, "Add a task", "Adding must clear the draft back to its placeholder.")

        let checkbox = app.switches["Buy milk"].firstMatch
        XCTAssertTrue(checkbox.waitForExistence(timeout: 2), "The todo must expose a switch.")
        toggle(checkbox)
        XCTAssertTrue(app.buttons["Clear 1 completed"].waitForExistence(timeout: 2), "Completing a todo must offer to clear it.")
        XCTAssertTrue(app.staticTexts[remaining].exists, "The remaining count must read \(remaining).")

        app.tabBars.buttons["Counter"].tap()
        let increment = app.buttons["Increment"]
        XCTAssertTrue(increment.waitForExistence(timeout: 5))
        increment.tap()
        increment.tap()
        XCTAssertTrue(app.staticTexts["Count 2"].waitForExistence(timeout: 2), "Two increments must show 2.")
        XCTAssertTrue(app.staticTexts[prime].exists, "2 is prime.")
        app.buttons["Reset"].tap()
        XCTAssertTrue(app.staticTexts["Count 0"].waitForExistence(timeout: 2), "Reset must return to 0.")
    }
}

/// A stock `Toggle` flips only when the tap lands on its switch, which sits at the trailing
/// edge of the element; the checkbox rows flip anywhere. Tapping the trailing edge works for
/// all three layers.
extension XCTestCase {
    @MainActor
    func toggle(_ element: XCUIElement) {
        element.coordinate(withNormalizedOffset: CGVector(dx: 0.92, dy: 0.5)).tap()
    }
}

/// Launch and interaction cost per UI layer, measured the same way for all three so the
/// comparison in the README quotes numbers from one run on one simulator.
final class TodoCounterPerformanceTests: XCTestCase {
    @MainActor func testRegistryLaunch() { measureLaunch("registry") }
    @MainActor func testPlainLaunch() { measureLaunch("plain") }
    @MainActor func testHandmadeLaunch() { measureLaunch("handmade") }

    @MainActor func testRegistryInteraction() { measureInteraction("registry") }
    @MainActor func testPlainInteraction() { measureInteraction("plain") }
    @MainActor func testHandmadeInteraction() { measureInteraction("handmade") }

    @MainActor
    private func measureLaunch(_ variant: String) {
        let app = XCUIApplication()
        app.launchArguments = ["-ui", variant]
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
        }
    }

    /// Adds five todos, completes them, and clears them, so every iteration starts empty.
    @MainActor
    private func measureInteraction(_ variant: String) {
        let app = XCUIApplication()
        app.launchArguments = ["-ui", variant]
        app.launch()
        let field = app.textFields["New task"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        let options = XCTMeasureOptions()
        options.iterationCount = 3
        measure(metrics: [XCTClockMetric()], options: options) {
            for index in 0..<5 {
                field.tap()
                field.typeText("Task \(index)\n")
            }
            for index in 0..<5 {
                toggle(app.switches["Task \(index)"].firstMatch)
            }
            app.buttons["Clear 5 completed"].tap()
            XCTAssertTrue(app.staticTexts["Nothing to do"].waitForExistence(timeout: 2))
        }
    }
}

/// Writes same-state screenshots of each layer for the comparison in the README. Runs only
/// when `TODOCOUNTER_CAPTURE_DIR` names a directory, so the regular test plan skips it.
final class TodoCounterCaptureTests: XCTestCase {
    @MainActor
    func testCapturesEachLayer() throws {
        guard let directory = ProcessInfo.processInfo.environment["TODOCOUNTER_CAPTURE_DIR"] else {
            throw XCTSkip("Set TODOCOUNTER_CAPTURE_DIR to capture the layers.")
        }
        for variant in ["registry", "plain", "handmade"] {
            let app = XCUIApplication()
            app.launchArguments = ["-ui", variant]
            app.launch()
            let field = app.textFields["New task"]
            XCTAssertTrue(field.waitForExistence(timeout: 5))
            field.tap()
            field.typeText("Buy milk\n")
            let checkbox = app.switches["Buy milk"].firstMatch
            XCTAssertTrue(checkbox.waitForExistence(timeout: 2))
            toggle(checkbox)
            XCTAssertTrue(app.buttons["Clear 1 completed"].waitForExistence(timeout: 2))
            try save(XCUIScreen.main.screenshot(), to: "\(directory)/todos-\(variant).png")
            app.tabBars.buttons["Counter"].tap()
            let increment = app.buttons["Increment"]
            XCTAssertTrue(increment.waitForExistence(timeout: 5))
            for _ in 0..<7 { increment.tap() }
            XCTAssertTrue(app.staticTexts["Count 7"].waitForExistence(timeout: 2))
            try save(XCUIScreen.main.screenshot(), to: "\(directory)/counter-\(variant).png")
            app.terminate()
        }
    }

    private func save(_ screenshot: XCUIScreenshot, to path: String) throws {
        try screenshot.pngRepresentation.write(to: URL(fileURLWithPath: path))
    }
}
