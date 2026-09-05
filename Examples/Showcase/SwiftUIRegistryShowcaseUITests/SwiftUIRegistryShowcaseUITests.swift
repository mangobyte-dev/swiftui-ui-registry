import UIKit
import XCTest

final class SwiftUIRegistryShowcaseUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    // MARK: - Launch and navigation helpers

    /// Every catalog launch resets the persisted tuning so a slider moved by a
    /// person on this simulator cannot change what the suite measures.
    @MainActor
    private func launchCatalog(_ arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-default-tuning"] + arguments
        app.launch()
        return app
    }

    @MainActor
    private func relaunchCatalog(_ app: XCUIApplication, _ arguments: [String]) {
        app.terminate()
        app.launchArguments = ["-default-tuning"] + arguments
        app.launch()
    }

    /// Opens one item's detail from its kind tab. Rows carry the
    /// `catalog.item.<name>` identifier, so the lookup does not depend on the
    /// row's combined label.
    @MainActor
    private func openItem(_ app: XCUIApplication, tab: String, name: String) {
        let tabButton = app.tabBars.buttons[tab]
        XCTAssertTrue(tabButton.waitForExistence(timeout: 5), "The \(tab) tab must exist.")
        tabButton.tap()
        let row = app.descendants(matching: .any)
            .matching(identifier: "catalog.item.\(name)")
            .firstMatch
        for _ in 0..<10 where !row.exists {
            app.swipeUp()
        }
        XCTAssertTrue(row.waitForExistence(timeout: 3), "The \(name) row must be listed under \(tab).")
        row.tap()
        XCTAssertTrue(
            app.navigationBars[name].waitForExistence(timeout: 5),
            "Opening \(name) must push its detail screen."
        )
    }

    @MainActor
    private func openBlock(_ app: XCUIApplication, _ name: String) {
        openItem(app, tab: "Blocks", name: name)
    }

    // MARK: - Catalog

    @MainActor
    func testEveryRegistryItemHasADemoInTheCaptureRoute() {
        // The `-item` route is what the screenshot pipeline and the website
        // depend on; an item without a demo renders the loud placeholder.
        let app = XCUIApplication()
        let unlabeled = NSPredicate(format: "label == ''")
        for name in RegistryItemNames.all {
            app.launchArguments = ["-item", name]
            app.launch()
            XCTAssertFalse(
                app.staticTexts["No demo for \(name)"].waitForExistence(timeout: 1),
                "\(name) must have a registered demo."
            )
            // Accessibility audit per demo: every interactive control and
            // every exposed image must carry a label. Decorative symbols are
            // hidden by the items, so an unlabeled image here is a defect.
            // Two kinds of unlabeled node are a control's own rendering,
            // not a defect, and are skipped: zero-area nodes, and a node
            // enclosed by a labeled element (the native switch inside a
            // labeled Toggle, the chevron inside a labeled disclosure
            // header). VoiceOver reads the enclosing element.
            let labeledFrames = app.descendants(matching: .any)
                .matching(NSPredicate(format: "label != ''"))
                .allElementsBoundByIndex
                .map(\.frame)
                .filter { $0.width > 0 && $0.height > 0 && $0.height < 200 }
            for (kind, query) in [
                ("button", app.buttons),
                ("switch", app.switches),
                ("image", app.images),
                ("text field", app.textFields),
                ("slider", app.sliders),
            ] {
                let offenders = query.matching(unlabeled).allElementsBoundByIndex.filter { element in
                    let frame = element.frame
                    guard frame.width > 0, frame.height > 0 else { return false }
                    return !labeledFrames.contains { $0.insetBy(dx: -2, dy: -2).contains(frame) }
                }
                XCTAssertTrue(
                    offenders.isEmpty,
                    "\(name) exposes a \(kind) without an accessibility label at \(offenders.map { $0.frame })."
                )
            }
            app.terminate()
        }
    }

    @MainActor
    func testCatalogSearchFiltersComponentsByTag() {
        let app = launchCatalog()
        let componentsTab = app.tabBars.buttons["Components"]
        XCTAssertTrue(componentsTab.waitForExistence(timeout: 5))
        let badgeRow = app.descendants(matching: .any).matching(identifier: "catalog.item.badge").firstMatch
        XCTAssertTrue(badgeRow.waitForExistence(timeout: 3))

        app.swipeDown()
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 3), "The catalog list must be searchable.")
        searchField.tap()
        searchField.typeText("shimmer")

        let skeletonRow = app.descendants(matching: .any).matching(identifier: "catalog.item.skeleton").firstMatch
        XCTAssertTrue(
            skeletonRow.waitForExistence(timeout: 3),
            "A tag-only query must still find the item that declares it."
        )
        XCTAssertFalse(badgeRow.exists, "Rows that match neither name, description, nor tag must drop out.")
    }

    // MARK: - Finance and nutrition blocks

    @MainActor
    func testInstalledFinanceBlockRendersInConsumerApp() {
        let app = launchCatalog()
        openBlock(app, "finance-overview")

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
        attachSnapshot(named: "finance-light", app: app)
        assertVisualSnapshot(named: "finance-light", app: app)
        XCTAssertFalse(
            app.staticTexts["Hello, World!"].exists,
            "The showcase must not fall back to its generated placeholder."
        )
    }

    @MainActor
    func testInstalledNutritionBlockRendersThroughNativeNavigation() {
        let app = launchCatalog()
        openBlock(app, "nutrition-overview")

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
        let app = launchCatalog()
        openBlock(app, "finance-overview")
        let regularTitle = app.staticTexts["Overview"]
        XCTAssertTrue(regularTitle.waitForExistence(timeout: 5))
        let regularHeight = regularTitle.frame.height

        relaunchCatalog(app, ["-accessibility-size"])
        openBlock(app, "finance-overview")
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
        let app = launchCatalog(["-empty-finance"])
        openBlock(app, "finance-overview")

        XCTAssertTrue(app.staticTexts["No recent activity"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["New transactions will appear here."].exists)
        XCTAssertFalse(
            app.staticTexts["Mishmash Bakery"].exists,
            "The empty state must replace transaction content rather than overlay it."
        )
    }

    @MainActor
    func testRightToLeftLaunchMirrorsTransactionReadingOrder() {
        let app = launchCatalog()
        openBlock(app, "finance-overview")
        let regularTitle = app.staticTexts["Mishmash Bakery"]
        let regularAmount = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "8.750")
        ).firstMatch
        XCTAssertTrue(regularTitle.waitForExistence(timeout: 5))
        XCTAssertTrue(regularAmount.exists)
        XCTAssertLessThan(regularTitle.frame.minX, regularAmount.frame.minX)

        relaunchCatalog(app, ["-right-to-left"])
        openBlock(app, "finance-overview")
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

    // MARK: - Stage 1 fixture

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
        XCTAssertTrue(primaryAction.exists)
        XCTAssertGreaterThanOrEqual(primaryAction.frame.height, 44)
        XCTAssertTrue(app.buttons["Save"].exists)
        XCTAssertTrue(app.buttons["Share"].exists)
        XCTAssertTrue(app.staticTexts["Ready"].exists)
        XCTAssertTrue(app.staticTexts["Text entry"].exists)
        XCTAssertTrue(app.textFields["Name"].exists)
        XCTAssertTrue(app.textViews["Notes"].exists)
        let acceptTerms = app.switches["Accept terms"]
        XCTAssertTrue(acceptTerms.exists)
        XCTAssertGreaterThanOrEqual(acceptTerms.frame.height, 44)
        let initialAcceptTermsValue = acceptTerms.value as? String
        acceptTerms.tap()
        XCTAssertNotEqual(
            acceptTerms.value as? String,
            initialAcceptTermsValue,
            "Checkbox activation must write through the caller-owned binding."
        )
        XCTAssertTrue(app.switches["Notifications"].exists)
        XCTAssertTrue(app.buttons["Bold"].exists)
        XCTAssertTrue(app.buttons["Italic"].exists)
        XCTAssertFalse(
            app.tabBars.firstMatch.exists,
            "The dedicated Stage 1 launch must not depend on the catalog tab flow."
        )

        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.exists)

        let selectionSection = app.staticTexts["Selection"]
        scroll(scrollView, until: selectionSection)
        XCTAssertTrue(selectionSection.exists)
        let segmentedTabs = app.segmentedControls.firstMatch
        XCTAssertTrue(segmentedTabs.exists)
        XCTAssertEqual(segmentedTabs.buttons.count, 2)

        let progressSection = app.staticTexts["Progress and value"]
        scroll(scrollView, until: progressSection)
        XCTAssertTrue(progressSection.exists)
        XCTAssertTrue(app.progressIndicators.firstMatch.exists)
        let volumeSlider = app.sliders["Volume"]
        XCTAssertTrue(volumeSlider.exists)
        for _ in 0..<4 {
            if volumeSlider.isHittable { break }
            scrollView.swipeUp()
        }
        XCTAssertTrue(volumeSlider.isHittable)

        let nativeLayoutSection = app.staticTexts["Native layout"]
        scroll(scrollView, until: nativeLayoutSection)
        XCTAssertTrue(nativeLayoutSection.exists)
        XCTAssertTrue(app.staticTexts["Leading content mirrors automatically"].exists)
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

        XCTAssertTrue(app.staticTexts["Stage 1 Components"].waitForExistence(timeout: 5))
        let primaryAction = app.buttons["Primary action"]
        XCTAssertTrue(primaryAction.exists)
        XCTAssertGreaterThanOrEqual(primaryAction.frame.height, 44)
        let acceptTerms = app.switches["Accept terms"]
        XCTAssertTrue(acceptTerms.exists)
        XCTAssertGreaterThanOrEqual(acceptTerms.frame.height, 44)
    }

    // MARK: - Stage 2 blocks

    @MainActor
    func testAuthReturnKeyMovesFocusFromIdentityToPasswordAndSubmits() {
        let app = launchCatalog()
        openBlock(app, "auth-form")

        let identityField = app.textFields["Email"]
        XCTAssertTrue(
            identityField.waitForExistence(timeout: 5),
            "The identity field title must be a real accessibility label, not placeholder-only text."
        )
        identityField.tap()
        identityField.typeText("mo@example.com")

        // Keyboard focus is not directly readable through public XCUITest API,
        // so the proof is where subsequently typed characters land: after the
        // Next return key they may only reach the secure password field.
        app.typeText("\n")
        app.typeText("correct horse")

        XCTAssertEqual(identityField.value as? String, "mo@example.com")
        let passwordField = app.secureTextFields["Password"]
        XCTAssertTrue(passwordField.exists)
        XCTAssertNotEqual(passwordField.value as? String, "Password")

        app.typeText("\n")
        XCTAssertTrue(
            app.staticTexts["We could not sign you in. Try again."].waitForExistence(timeout: 5),
            "Return in the password field must trigger the caller-owned submit action."
        )
    }

    @MainActor
    func testAuthSubmitDisablesFieldsAndSubmitControlWhileSubmitting() {
        let app = launchCatalog()
        openBlock(app, "auth-form")

        let identityField = app.textFields["Email"]
        XCTAssertTrue(identityField.waitForExistence(timeout: 5))
        identityField.tap()
        identityField.typeText("mo@example.com")
        let passwordField = app.secureTextFields["Password"]
        passwordField.tap()
        passwordField.typeText("correct horse")
        app.typeText("\n")

        let submitButton = app.buttons["Sign in"]
        XCTAssertTrue(submitButton.waitForExistence(timeout: 2))
        XCTAssertFalse(submitButton.isEnabled, "The submit control must be disabled while a submission is in flight.")
        XCTAssertFalse(identityField.isEnabled)
        XCTAssertFalse(passwordField.isEnabled)

        XCTAssertTrue(app.staticTexts["We could not sign you in. Try again."].waitForExistence(timeout: 5))
        XCTAssertTrue(submitButton.isEnabled, "Controls must re-enable when the caller clears isSubmitting.")
    }

    @MainActor
    func testAuthValidationSurfacesFieldAndFormErrorCopy() {
        let app = launchCatalog()
        openBlock(app, "auth-form")

        XCTAssertTrue(app.staticTexts["Welcome back"].waitForExistence(timeout: 5))
        attachSnapshot(named: "auth-light", app: app)
        assertVisualSnapshot(named: "auth-light", app: app)

        app.buttons["Sign in"].tap()

        XCTAssertTrue(
            app.staticTexts["Enter a valid email address"].waitForExistence(timeout: 2),
            "An invalid identity must surface its error copy to accessibility, never color alone."
        )
        XCTAssertTrue(app.staticTexts["Enter your password"].exists)

        let identityField = app.textFields["Email"]
        identityField.tap()
        identityField.typeText("mo@example.com")
        let passwordField = app.secureTextFields["Password"]
        passwordField.tap()
        passwordField.typeText("correct horse")
        app.typeText("\n")

        XCTAssertTrue(app.staticTexts["We could not sign you in. Try again."].waitForExistence(timeout: 5))
        XCTAssertFalse(
            app.staticTexts["Enter a valid email address"].exists,
            "Corrected fields must drop stale error copy rather than accumulate it."
        )
    }

    @MainActor
    func testSettingsRowsWriteThroughCallerBindingsAndReportDisabledState() {
        let app = launchCatalog()
        openBlock(app, "settings-section")

        XCTAssertTrue(app.staticTexts["Notifications"].waitForExistence(timeout: 5))
        attachSnapshot(named: "settings-light", app: app)
        assertVisualSnapshot(named: "settings-light", app: app)

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
        XCTAssertFalse(marketingToggle.isEnabled)
        XCTAssertTrue(app.staticTexts["Managed by your organization's privacy policy."].exists)

        let scrollView = app.scrollViews.firstMatch
        let signOutButton = app.buttons["Sign out"]
        scroll(scrollView, until: signOutButton)
        for _ in 0..<4 {
            if signOutButton.isHittable { break }
            scrollView.swipeUp()
        }
        signOutButton.tap()
        XCTAssertTrue(app.staticTexts["Signed out."].waitForExistence(timeout: 2))
    }

    @MainActor
    func testStageTwoScreensAdaptToAccessibilitySizeAndRightToLeft() {
        let app = launchCatalog()
        openBlock(app, "auth-form")
        let regularTitle = app.staticTexts["Welcome back"]
        XCTAssertTrue(regularTitle.waitForExistence(timeout: 5))
        let regularTitleHeight = regularTitle.frame.height
        let regularSecondary = app.buttons["Forgot password?"]
        XCTAssertTrue(regularSecondary.exists)
        let regularSecondaryMinX = regularSecondary.frame.minX
        app.navigationBars.buttons.firstMatch.tap()
        openBlock(app, "settings-section")
        let regularFooter = app.staticTexts["Quiet hours apply to every channel."]
        XCTAssertTrue(regularFooter.waitForExistence(timeout: 5))
        let regularFooterMinX = regularFooter.frame.minX

        relaunchCatalog(app, ["-accessibility-size", "-right-to-left"])
        openBlock(app, "auth-form")

        let accessibilityTitle = app.staticTexts["Welcome back"]
        XCTAssertTrue(accessibilityTitle.waitForExistence(timeout: 5))
        XCTAssertGreaterThan(accessibilityTitle.frame.height, regularTitleHeight)
        XCTAssertTrue(app.textFields["Email"].exists)
        XCTAssertTrue(app.secureTextFields["Password"].exists)
        let scrollView = app.scrollViews.firstMatch
        let submitButton = app.buttons["Sign in"]
        scroll(scrollView, until: submitButton)
        XCTAssertTrue(submitButton.exists)
        let mirroredSecondary = app.buttons["Forgot password?"]
        XCTAssertTrue(mirroredSecondary.exists)
        XCTAssertGreaterThan(mirroredSecondary.frame.minX, regularSecondaryMinX)

        app.navigationBars.buttons.firstMatch.tap()
        openBlock(app, "settings-section")
        XCTAssertTrue(app.staticTexts["Notifications"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.switches["Transaction alerts"].exists)
        let mirroredFooter = app.staticTexts["Quiet hours apply to every channel."]
        XCTAssertTrue(mirroredFooter.exists)
        XCTAssertGreaterThan(mirroredFooter.frame.minX, regularFooterMinX)
    }

    // MARK: - Stage 3 block

    @MainActor
    func testActivityFeedStatesAreDistinguishableAndPlaceholdersNeverAct() {
        let app = launchCatalog()
        openBlock(app, "activity-feed")

        XCTAssertTrue(app.staticTexts["Activity"].waitForExistence(timeout: 5))
        attachSnapshot(named: "activity-light", app: app)
        assertVisualSnapshot(named: "activity-light", app: app)

        // Loaded: an unread row states its unread value, not only a dot.
        let unreadRow = app.buttons.matching(
            NSPredicate(format: "label CONTAINS %@", "Mishmash Bakery")
        ).firstMatch
        XCTAssertTrue(unreadRow.exists)
        XCTAssertEqual(unreadRow.value as? String, "Unread", "Unread state must be spoken, never color alone.")

        // Loading: the placeholder is one labeled element and cannot select.
        let statePicker = app.segmentedControls["activity.state"]
        XCTAssertTrue(statePicker.exists)
        statePicker.buttons["Loading"].tap()
        let placeholder = app.otherElements["Loading activity"]
        XCTAssertTrue(placeholder.waitForExistence(timeout: 2), "The skeleton must expose one loading element.")
        XCTAssertFalse(unreadRow.exists, "Placeholder rows must not remain reachable as buttons.")
        placeholder.tap()
        XCTAssertFalse(
            app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "Selected")).firstMatch.exists,
            "Tapping a placeholder must never trigger the caller's selection."
        )

        // Empty: native ContentUnavailableView copy replaces the rows.
        statePicker.buttons["Empty"].tap()
        XCTAssertTrue(app.staticTexts["You're all caught up"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["New activity will appear here."].exists)

        // Loaded again: selection, the accordion, and the notice dismissal all
        // run caller code.
        statePicker.buttons["Loaded"].tap()
        XCTAssertTrue(unreadRow.waitForExistence(timeout: 2))
        unreadRow.tap()
        XCTAssertTrue(app.staticTexts["Selected bakery."].waitForExistence(timeout: 2))

        let scrollView = app.scrollViews.firstMatch
        let earlier = app.buttons["Earlier"]
        scroll(scrollView, until: earlier)
        XCTAssertEqual(earlier.value as? String, "Collapsed")
        earlier.tap()
        XCTAssertTrue(app.staticTexts["Mobile service"].waitForExistence(timeout: 2))
        XCTAssertEqual(earlier.value as? String, "Expanded")

        scrollView.swipeDown()
        let dismiss = app.buttons["Dismiss"]
        XCTAssertTrue(dismiss.waitForExistence(timeout: 2))
        dismiss.tap()
        XCTAssertFalse(
            app.staticTexts["Card delivery delayed"].waitForExistence(timeout: 1),
            "Dismissing the notice must run the caller's handler and remove the alert."
        )
    }

    // MARK: - Tuning panel

    @MainActor
    func testTuningPanelExportsTheSelectedPresetAsSwift() {
        let app = launchCatalog()
        let tuneTab = app.tabBars.buttons["Tune"]
        XCTAssertTrue(tuneTab.waitForExistence(timeout: 5))
        tuneTab.tap()

        let graphite = app.buttons["Graphite"]
        XCTAssertTrue(graphite.waitForExistence(timeout: 5), "Foundation presets must be one tap away.")
        graphite.tap()

        // Reading UIPasteboard from the test process raises the simulator's
        // paste-permission prompt and hangs the suite, so the proof is the
        // Swift section the panel renders from the same export string.
        XCTAssertTrue(app.buttons["Copy Swift"].exists)
        let swiftRow = app.buttons["Swift"]
        XCTAssertTrue(swiftRow.waitForExistence(timeout: 3), "The export must sit one tap below the presets.")
        swiftRow.tap()
        let export = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "accent: .primary")
        ).firstMatch
        XCTAssertTrue(export.waitForExistence(timeout: 3), "The Graphite preset must export its primary accent.")
        XCTAssertTrue(export.label.contains("RegistryTheme("), "The export must be the foundation initializer.")
        XCTAssertTrue(export.label.contains(".registryTheme(theme)"), "The export must show the one-line root setup.")
    }

    @MainActor
    func testTuningPanelImportsAPastedThemeIntoTheKnobs() {
        let app = launchCatalog()
        let tuneTab = app.tabBars.buttons["Tune"]
        XCTAssertTrue(tuneTab.waitForExistence(timeout: 5))
        tuneTab.tap()

        app.buttons["Import"].tap()
        let editor = app.textViews["Theme Swift"]
        XCTAssertTrue(editor.waitForExistence(timeout: 3), "The import sheet must offer a labeled editor.")
        editor.tap()
        // A subset of arguments is enough: only the named knobs change.
        editor.typeText("RegistryTheme(accent: .rose, disabledOpacity: 0.3, metrics: RegistryMetrics(cardRadius: 20))")
        app.buttons["Apply"].tap()

        let swiftRow = app.buttons["Swift"]
        XCTAssertTrue(swiftRow.waitForExistence(timeout: 3))
        swiftRow.tap()
        let export = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "cardRadius: 20")
        ).firstMatch
        XCTAssertTrue(export.waitForExistence(timeout: 3), "The imported card radius must round-trip into the export.")
        XCTAssertTrue(export.label.contains("accent: .pink"), "The rose preset name must map to its pink accent.")
        XCTAssertTrue(export.label.contains("disabledOpacity: 0.300"))
        XCTAssertTrue(export.label.contains("standardSpacing: 16"), "Knobs the paste does not name must keep their values.")

        // Text without an initializer is refused, and the knobs stay put.
        app.buttons["Import"].tap()
        let editorAgain = app.textViews["Theme Swift"]
        XCTAssertTrue(editorAgain.waitForExistence(timeout: 3))
        editorAgain.tap()
        editorAgain.typeText("nothing here")
        app.buttons["Apply"].tap()
        XCTAssertTrue(app.staticTexts["No RegistryTheme( initializer found in the pasted text."].waitForExistence(timeout: 2))
    }

    // MARK: - Helpers

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
            0.015,
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

        // 192 by 384 keeps a whole tab bar or nav bar from hiding inside the
        // tolerance while still ignoring glyph-level rendering noise.
        let width = 192
        let height = 384
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


