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
    func testStageOneCatalogRendersInstalledNativeControlsInAdaptiveEnvironments() {
        let app = XCUIApplication()
        app.launchArguments = ["-stage-one", "-accessibility-size", "-right-to-left"]
        app.launch()

        XCTAssertTrue(
            app.staticTexts["Stage 1 Components"].waitForExistence(timeout: 5),
            "The Stage 1 launch must render the installed catalog through the consumer target."
        )
        let primaryAction = app.buttons["Primary action"]
        XCTAssertTrue(
            primaryAction.exists,
            "The native primary button must render through its installed style."
        )
        XCTAssertGreaterThanOrEqual(
            primaryAction.frame.height,
            44,
            "Registry button styling must preserve the minimum interaction height."
        )
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(
            saveButton.exists,
            "Icon-only button-group controls must retain their native initializer labels."
        )
        XCTAssertTrue(
            app.buttons["Share"].exists,
            "Button-group styling must preserve each native button accessibility label."
        )
        XCTAssertTrue(app.staticTexts["Ready"].exists)
        XCTAssertTrue(app.staticTexts["Text entry"].exists)
        XCTAssertTrue(app.textFields["Name"].exists)
        XCTAssertTrue(
            app.textViews["Notes"].exists,
            "The textarea modifier must apply its required caller-supplied accessibility label."
        )
        let acceptTerms = app.switches["Accept terms"]
        XCTAssertTrue(
            acceptTerms.exists,
            "Checkbox styling must retain native Toggle accessibility semantics."
        )
        XCTAssertGreaterThanOrEqual(
            acceptTerms.frame.height,
            44,
            "Checkbox styling must preserve the minimum interaction height."
        )
        let initialAcceptTermsValue = acceptTerms.value as? String
        acceptTerms.tap()
        XCTAssertNotEqual(
            acceptTerms.value as? String,
            initialAcceptTermsValue,
            "Checkbox activation must write through the caller-owned binding."
        )
        XCTAssertTrue(
            app.switches["Notifications"].exists,
            "Switch styling must retain native Toggle accessibility semantics."
        )
        let boldToggle = app.buttons["Bold"]
        XCTAssertTrue(
            boldToggle.exists,
            "Icon-only button toggles must retain their native initializer labels."
        )
        XCTAssertTrue(
            app.buttons["Italic"].exists,
            "Toggle-group styling must preserve each native Toggle accessibility label."
        )
        XCTAssertFalse(
            app.tabBars.firstMatch.exists,
            "The dedicated Stage 1 launch must not depend on the product-block tab flow."
        )

        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(
            scrollView.exists,
            "The catalog must remain scrollable when accessibility text expands its content."
        )

        let selectionSection = app.staticTexts["Selection"]
        scroll(scrollView, until: selectionSection)
        XCTAssertTrue(
            selectionSection.exists,
            "The installed selection styles must remain reachable at accessibility sizes."
        )
        let segmentedTabs = app.segmentedControls.firstMatch
        XCTAssertTrue(
            segmentedTabs.exists,
            "Local tabs must retain native segmented-picker semantics."
        )
        XCTAssertEqual(
            segmentedTabs.buttons.count,
            2,
            "The caller-supplied local tab options must remain visible to accessibility."
        )

        let progressSection = app.staticTexts["Progress and value"]
        scroll(scrollView, until: progressSection)
        XCTAssertTrue(
            progressSection.exists,
            "The installed progress and value styles must remain reachable."
        )
        XCTAssertTrue(
            app.progressIndicators.firstMatch.exists,
            "Progress styles must retain native progress-indicator semantics."
        )
        let volumeSlider = app.sliders["Volume"]
        XCTAssertTrue(
            volumeSlider.exists,
            "Slider treatment must retain the caller-supplied native adjustable control."
        )
        for _ in 0..<4 {
            if volumeSlider.isHittable { break }
            scrollView.swipeUp()
        }
        XCTAssertTrue(
            volumeSlider.isHittable,
            "The native slider must remain reachable at accessibility text sizes."
        )

        let nativeLayoutSection = app.staticTexts["Native layout"]
        scroll(scrollView, until: nativeLayoutSection)
        XCTAssertTrue(
            nativeLayoutSection.exists,
            "Native-only aspect-ratio and direction guidance must remain in the catalog."
        )
        XCTAssertTrue(
            app.staticTexts["Leading content mirrors automatically"].exists,
            "Direction guidance must render under the right-to-left environment."
        )
    }

    @MainActor
    func testStageOneControlsMeetMinimumHitTargetAtDefaultTextSize() {
        // The adaptive test launches at accessibility3, where the label's own
        // grown text already exceeds 44pt, so its height assertions cannot catch
        // the removal of the min-hit-size styling. This launch fixes the type
        // size at the system default, where only the guarded
        // RegistryMetrics.minimumHitSize frame keeps the controls at 44pt.
        let app = XCUIApplication()
        app.launchArguments = ["-stage-one"]
        app.launch()

        XCTAssertTrue(
            app.staticTexts["Stage 1 Components"].waitForExistence(timeout: 5),
            "The Stage 1 launch must render the installed catalog through the consumer target."
        )
        let primaryAction = app.buttons["Primary action"]
        XCTAssertTrue(primaryAction.exists)
        XCTAssertGreaterThanOrEqual(
            primaryAction.frame.height,
            44,
            "Registry button styling must preserve the minimum interaction height at the default text size."
        )
        let acceptTerms = app.switches["Accept terms"]
        XCTAssertTrue(acceptTerms.exists)
        XCTAssertGreaterThanOrEqual(
            acceptTerms.frame.height,
            44,
            "Checkbox styling must preserve the minimum interaction height at the default text size."
        )
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
    func testAuthReturnKeyMovesFocusFromIdentityToPasswordAndSubmits() {
        let app = XCUIApplication()
        app.launch()

        let authTab = app.tabBars.buttons["Authentication"]
        XCTAssertTrue(authTab.waitForExistence(timeout: 5))
        authTab.tap()

        let identityField = app.textFields["Email"]
        XCTAssertTrue(
            identityField.waitForExistence(timeout: 5),
            "The identity field title must be a real accessibility label, not placeholder-only text."
        )
        identityField.tap()
        identityField.typeText("mo@example.com")

        // Keyboard focus is not directly readable through public XCUITest API,
        // so the proof is where subsequently typed characters land: after the
        // Next return key they may only reach the secure password field. A
        // copy that drops .submitLabel(.next)/.onSubmit focus chaining leaves
        // focus in the identity field and fails both assertions below.
        app.typeText("\n")
        app.typeText("correct horse")

        XCTAssertEqual(
            identityField.value as? String,
            "mo@example.com",
            "Return in the identity field must move focus onward, not keep collecting characters."
        )
        let passwordField = app.secureTextFields["Password"]
        XCTAssertTrue(passwordField.exists)
        XCTAssertNotEqual(
            passwordField.value as? String,
            "Password",
            "Characters typed after the identity return key must land in the password field."
        )

        // The Go return key in the password field must run the caller's
        // onSubmit: the harness flips isSubmitting and then reports a form
        // error, which is the observable submit evidence.
        app.typeText("\n")
        XCTAssertTrue(
            app.staticTexts["We could not sign you in. Try again."].waitForExistence(timeout: 5),
            "Return in the password field must trigger the caller-owned submit action."
        )
    }

    @MainActor
    func testAuthSubmitDisablesFieldsAndSubmitControlWhileSubmitting() {
        let app = XCUIApplication()
        app.launch()

        let authTab = app.tabBars.buttons["Authentication"]
        XCTAssertTrue(authTab.waitForExistence(timeout: 5))
        authTab.tap()

        let identityField = app.textFields["Email"]
        XCTAssertTrue(identityField.waitForExistence(timeout: 5))
        identityField.tap()
        identityField.typeText("mo@example.com")
        let passwordField = app.secureTextFields["Password"]
        passwordField.tap()
        passwordField.typeText("correct horse")
        app.typeText("\n")

        // The harness holds isSubmitting for two seconds. A copy that ignores
        // isSubmitting keeps every control enabled and fails these checks.
        let submitButton = app.buttons["Sign in"]
        XCTAssertTrue(
            submitButton.waitForExistence(timeout: 2),
            "The submit control must keep its title as its accessibility label while showing progress."
        )
        XCTAssertFalse(
            submitButton.isEnabled,
            "The submit control must be disabled while a submission is in flight."
        )
        XCTAssertFalse(
            identityField.isEnabled,
            "The identity field must be disabled while a submission is in flight."
        )
        XCTAssertFalse(
            passwordField.isEnabled,
            "The password field must be disabled while a submission is in flight."
        )

        XCTAssertTrue(
            app.staticTexts["We could not sign you in. Try again."].waitForExistence(timeout: 5),
            "The harness submit must complete with its observable form error."
        )
        XCTAssertTrue(
            submitButton.isEnabled,
            "Controls must re-enable when the caller clears isSubmitting."
        )
    }

    @MainActor
    func testAuthValidationSurfacesFieldAndFormErrorCopy() {
        let app = XCUIApplication()
        app.launch()

        let authTab = app.tabBars.buttons["Authentication"]
        XCTAssertTrue(authTab.waitForExistence(timeout: 5))
        authTab.tap()

        XCTAssertTrue(
            app.staticTexts["Welcome back"].waitForExistence(timeout: 5),
            "The installed auth block must render through the consumer target."
        )
        attachSnapshot(named: "auth-light", app: app)
        assertVisualSnapshot(named: "auth-light", app: app)

        app.buttons["Sign in"].tap()

        // The block's documented accessibility mechanism for invalid fields is
        // a visible footnote message plus the same message as the field's
        // accessibility hint and an AccessibilityNotification.Announcement.
        // XCUITest cannot read accessibilityHint or observe announcement
        // delivery, so the strongest observable proxy is the error copy being
        // real accessibility elements; the hint and announcement source lines
        // are pinned structurally by
        // test_auth_block_keeps_credential_autofill_and_error_announcements.
        XCTAssertTrue(
            app.staticTexts["Enter a valid email address"].waitForExistence(timeout: 2),
            "An invalid identity must surface its error copy to accessibility, never color alone."
        )
        XCTAssertTrue(
            app.staticTexts["Enter your password"].exists,
            "An empty password must surface its error copy to accessibility."
        )

        let identityField = app.textFields["Email"]
        identityField.tap()
        identityField.typeText("mo@example.com")
        let passwordField = app.secureTextFields["Password"]
        passwordField.tap()
        passwordField.typeText("correct horse")
        app.typeText("\n")

        XCTAssertTrue(
            app.staticTexts["We could not sign you in. Try again."].waitForExistence(timeout: 5),
            "A failed submission must surface the caller-provided form error copy."
        )
        XCTAssertFalse(
            app.staticTexts["Enter a valid email address"].exists,
            "Corrected fields must drop stale error copy rather than accumulate it."
        )
    }

    @MainActor
    func testSettingsRowsWriteThroughCallerBindingsAndReportDisabledState() {
        let app = XCUIApplication()
        app.launch()

        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        XCTAssertTrue(
            app.staticTexts["Notifications"].waitForExistence(timeout: 5),
            "The installed settings block must render through the consumer target."
        )
        attachSnapshot(named: "settings-light", app: app)
        assertVisualSnapshot(named: "settings-light", app: app)

        // The caption under the section mirrors the caller-owned binding, so a
        // toggle that renders but does not write through the binding fails here.
        let alertsToggle = app.switches["Transaction alerts"]
        XCTAssertTrue(alertsToggle.exists)
        XCTAssertTrue(app.staticTexts["Transaction alerts are on."].exists)
        alertsToggle.tap()
        XCTAssertTrue(
            app.staticTexts["Transaction alerts are off."].waitForExistence(timeout: 2),
            "Flipping the switch must write through the caller-owned binding."
        )

        let marketingToggle = app.switches["Marketing messages"]
        XCTAssertTrue(marketingToggle.exists)
        XCTAssertFalse(
            marketingToggle.isEnabled,
            "The organization-managed row must report isEnabled false to accessibility."
        )
        XCTAssertTrue(
            app.staticTexts["Managed by your organization's privacy policy."].exists,
            "A disabled row must keep its visible explanation outside the disabled subtree."
        )

        let scrollView = app.scrollViews.firstMatch
        let signOutButton = app.buttons["Sign out"]
        scroll(scrollView, until: signOutButton)
        for _ in 0..<4 {
            if signOutButton.isHittable { break }
            scrollView.swipeUp()
        }
        signOutButton.tap()
        XCTAssertTrue(
            app.staticTexts["Signed out."].waitForExistence(timeout: 2),
            "Activating the destructive row must run the caller-owned action."
        )
    }

    @MainActor
    func testStageTwoScreensAdaptToAccessibilitySizeAndRightToLeft() {
        let app = XCUIApplication()
        app.launch()
        let authTab = app.tabBars.buttons["Authentication"]
        XCTAssertTrue(authTab.waitForExistence(timeout: 5))
        authTab.tap()
        let regularTitle = app.staticTexts["Welcome back"]
        XCTAssertTrue(regularTitle.waitForExistence(timeout: 5))
        let regularTitleHeight = regularTitle.frame.height
        let regularSecondary = app.buttons["Forgot password?"]
        XCTAssertTrue(regularSecondary.exists)
        let regularSecondaryMinX = regularSecondary.frame.minX
        app.tabBars.buttons["Settings"].tap()
        let regularFooter = app.staticTexts["Quiet hours apply to every channel."]
        XCTAssertTrue(regularFooter.waitForExistence(timeout: 5))
        let regularFooterMinX = regularFooter.frame.minX
        app.terminate()

        app.launchArguments = ["-accessibility-size", "-right-to-left"]
        app.launch()
        let mirroredAuthTab = app.tabBars.buttons["Authentication"]
        XCTAssertTrue(mirroredAuthTab.waitForExistence(timeout: 5))
        mirroredAuthTab.tap()

        let accessibilityTitle = app.staticTexts["Welcome back"]
        XCTAssertTrue(accessibilityTitle.waitForExistence(timeout: 5))
        XCTAssertGreaterThan(
            accessibilityTitle.frame.height,
            regularTitleHeight,
            "The auth block must scale with system typography rather than hardcode a size."
        )
        XCTAssertTrue(app.textFields["Email"].exists)
        XCTAssertTrue(app.secureTextFields["Password"].exists)
        let scrollView = app.scrollViews.firstMatch
        let submitButton = app.buttons["Sign in"]
        scroll(scrollView, until: submitButton)
        XCTAssertTrue(
            submitButton.exists,
            "The submit control must remain reachable at accessibility text sizes."
        )
        let mirroredSecondary = app.buttons["Forgot password?"]
        XCTAssertTrue(mirroredSecondary.exists)
        XCTAssertGreaterThan(
            mirroredSecondary.frame.minX,
            regularSecondaryMinX,
            "Leading-aligned auth content must mirror without a separate RTL implementation."
        )

        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(
            app.staticTexts["Notifications"].waitForExistence(timeout: 5),
            "The settings block must render under accessibility size and right-to-left together."
        )
        XCTAssertTrue(app.switches["Transaction alerts"].exists)
        let mirroredFooter = app.staticTexts["Quiet hours apply to every channel."]
        XCTAssertTrue(mirroredFooter.exists)
        XCTAssertGreaterThan(
            mirroredFooter.frame.minX,
            regularFooterMinX,
            "Leading-aligned settings content must mirror without a separate RTL implementation."
        )
    }

    @MainActor
    private func scroll(_ scrollView: XCUIElement, until element: XCUIElement) {
        for _ in 0..<8 {
            if element.exists { return }
            scrollView.swipeUp()
        }
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
