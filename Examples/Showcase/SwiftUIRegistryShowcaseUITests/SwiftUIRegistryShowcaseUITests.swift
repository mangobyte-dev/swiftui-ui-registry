import UIKit
import XCTest

final class SwiftUIRegistryShowcaseUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testInstalledFinanceBlockRendersInConsumerApp() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(
            app.staticTexts["Overview"].waitForExistence(timeout: 5),
            "The source-installed finance block must render through the consumer target."
        )
        XCTAssertTrue(app.staticTexts["Available balance"].exists)
        XCTAssertTrue(app.staticTexts["Recent activity"].exists)
        let firstTransaction = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "Mishmash Bakery")
        ).firstMatch
        XCTAssertTrue(firstTransaction.exists)
        XCTAssertTrue(firstTransaction.label.contains("Today, 09:41"))
        XCTAssertTrue(firstTransaction.label.contains("8.750"))
        XCTAssertTrue(app.tabBars.buttons["Nutrition"].exists)
        attachSnapshot(named: "finance-light", app: app)
        assertVisualSnapshot(named: "finance-light", app: app)
        XCTAssertFalse(
            app.staticTexts["Hello, World!"].exists,
            "The showcase must not fall back to its generated placeholder."
        )
    }

    @MainActor
    func testInstalledNutritionBlockRendersThroughNativeTabNavigation() {
        let app = XCUIApplication()
        app.launch()

        let nutritionTab = app.tabBars.buttons["Nutrition"]
        XCTAssertTrue(nutritionTab.waitForExistence(timeout: 5))
        nutritionTab.tap()

        XCTAssertTrue(
            app.staticTexts["Macronutrients"].waitForExistence(timeout: 5),
            "The second domain must render from installed registry source."
        )
        XCTAssertTrue(app.staticTexts["Protein"].exists)
        XCTAssertTrue(app.buttons["Log food"].exists)
        attachSnapshot(named: "nutrition-light", app: app)
        assertVisualSnapshot(named: "nutrition-light", app: app)
    }

    @MainActor
    func testAccessibilitySizeLaunchExpandsSystemTypography() {
        let app = XCUIApplication()
        app.launch()
        let regularTitle = app.staticTexts["Overview"]
        XCTAssertTrue(regularTitle.waitForExistence(timeout: 5))
        let regularHeight = regularTitle.frame.height
        app.terminate()

        app.launchArguments = ["-accessibility-size"]
        app.launch()
        let accessibilityTitle = app.staticTexts["Overview"]
        XCTAssertTrue(accessibilityTitle.waitForExistence(timeout: 5))

        XCTAssertGreaterThan(
            accessibilityTitle.frame.height,
            regularHeight,
            "The accessibility launch must exercise larger system text rather than only relaunching the default UI."
        )
    }

    @MainActor
    func testEmptyFinanceStateExplainsWhereFutureActivityAppears() {
        let app = XCUIApplication()
        app.launchArguments = ["-empty-finance"]
        app.launch()

        XCTAssertTrue(app.staticTexts["No recent activity"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["New transactions will appear here."].exists)
        XCTAssertFalse(
            app.staticTexts["Mishmash Bakery"].exists,
            "The empty state must replace transaction content rather than overlay it."
        )
    }

    @MainActor
    func testRightToLeftLaunchMirrorsTransactionReadingOrder() {
        let app = XCUIApplication()
        app.launch()
        let regularTitle = app.staticTexts["Mishmash Bakery"]
        let regularAmount = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "8.750")
        ).firstMatch
        XCTAssertTrue(regularTitle.waitForExistence(timeout: 5))
        XCTAssertTrue(regularAmount.exists)
        XCTAssertLessThan(regularTitle.frame.minX, regularAmount.frame.minX)
        app.terminate()

        app.launchArguments = ["-right-to-left"]
        app.launch()
        let mirroredTitle = app.staticTexts["Mishmash Bakery"]
        let mirroredAmount = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "8.750")
        ).firstMatch
        XCTAssertTrue(mirroredTitle.waitForExistence(timeout: 5))
        XCTAssertTrue(mirroredAmount.exists)

        XCTAssertGreaterThan(
            mirroredTitle.frame.minX,
            mirroredAmount.frame.minX,
            "Leading and trailing composition must mirror without a separate RTL implementation."
        )
    }

    @MainActor
    private func attachSnapshot(named name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    private func assertVisualSnapshot(named name: String, app: XCUIApplication) {
        let bundle = Bundle(for: Self.self)
        let referenceURL = bundle.url(
            forResource: name,
            withExtension: "png",
            subdirectory: "ReferenceImages"
        ) ?? bundle.url(forResource: name, withExtension: "png")
        guard let referenceURL, let reference = UIImage(contentsOfFile: referenceURL.path) else {
            XCTFail("Missing approved visual reference: \(name).png")
            return
        }

        let actual = app.screenshot().image
        guard let actualPixels = normalizedPixels(actual),
              let referencePixels = normalizedPixels(reference) else {
            XCTFail("Could not normalize visual snapshot: \(name)")
            return
        }

        let totalDifference = zip(actualPixels, referencePixels).reduce(0) {
            $0 + abs(Int($1.0) - Int($1.1))
        }
        let normalizedDifference = Double(totalDifference) /
            Double(actualPixels.count * Int(UInt8.max))

        XCTAssertLessThanOrEqual(
            normalizedDifference,
            0.02,
            "Visual snapshot \(name) changed by \(normalizedDifference.formatted(.percent.precision(.fractionLength(2)))); review before replacing its approved reference."
        )
    }

    private func normalizedPixels(_ image: UIImage) -> [UInt8]? {
        guard let source = image.cgImage else { return nil }
        let cropTop = Int(Double(source.height) * 0.07)
        guard let cropped = source.cropping(to: CGRect(
            x: 0,
            y: cropTop,
            width: source.width,
            height: source.height - cropTop
        )) else { return nil }

        let width = 96
        let height = 192
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        let created = pixels.withUnsafeMutableBytes { buffer in
            guard let context = CGContext(
                data: buffer.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return false }
            context.interpolationQuality = .low
            context.draw(cropped, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        return created ? pixels : nil
    }
}
