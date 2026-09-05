# Visual testing

## Contract

The showcase UI tests compare the finance, nutrition, authentication, settings, activity, and command-search screens with approved references under `Examples/Showcase/SwiftUIRegistryShowcaseUITests/ReferenceImages/`

The contract is pinned to a light-mode iPhone 17 running iOS 27.0. Native controls and tab presentation intentionally change across Apple platform versions, so a different runtime is visual review evidence rather than a valid baseline runner

## Comparison

`SwiftUIRegistryShowcaseUITests.swift`:

1. Captures the app through `XCUIApplication.screenshot()`
2. Removes the top 7 percent containing volatile status-bar content
3. Normalizes both images to 192 by 384 RGBA pixels
4. Computes mean absolute channel difference
5. Fails when the normalized difference exceeds 1.5 percent

Semantic UI assertions remain separate. The image check protects layout, hierarchy, surfaces, color distribution, and major typography without treating the changing clock as product output

## Approved references

- `finance-light.png`
- `nutrition-light.png`
- `auth-light.png`
- `settings-light.png`
- `activity-light.png`
- `command-light.png`

GOLDEN-CHANGE: these initial references were approved after iPhone and iPad review of both domains, an iOS 18 deployment-floor run, and an accessibility-size run. Future reference changes require the same explicit note in the reviewing change

GOLDEN-CHANGE: the deployment floor was raised to iOS 26, so a floor-26 app can no longer launch on the previous iPhone 16 Pro iOS 18.0 pin and the iOS 18 references became unrunnable rather than merely stale. Both references were recaptured on the light-mode iPhone 17 iOS 27.0 runtime, where system controls and presentations render Liquid Glass, most visibly the floating tab bar. Screen content, hierarchy, and copy are unchanged. Capture on an iOS 26 runtime is deferred until a 26 runtime or device is available; iOS 27.0 is the only installed runtime that can execute the app

GOLDEN-CHANGE (2026-09-01): `auth-light.png` and `settings-light.png` were added for the two Stage 2 blocks. Each shows the pristine light-mode screen on the pinned iPhone 17 iOS 27.0 runtime: the auth screen with the Welcome back card, empty Email and Password fields, Sign in button, and Forgot password? link; the settings screen with the Notifications header, five rows with separators, the dimmed organization-managed Marketing messages row with its explanation, the Currency select, the destructive Sign out button, the footer, and the binding caption. Both images were captured through the suite's kept attachments, exported with `xcrun xcresulttool export attachments`, and reviewed directly before approval. The existing finance and nutrition references are untouched

GOLDEN-CHANGE (2026-09-01): `finance-light.png` and `nutrition-light.png` were recaptured on the same light-mode iPhone 17 iOS 27.0 pin. The prior references were approved before the Authentication and Settings tabs existed and showed a stale two-tab bar; Stage 2 grew the tab bar from two to four tabs (Finance, Nutrition, Authentication, Settings), a difference the 2 percent tolerance silently absorbed. The recapture updates the references to the intended current product state. Screen content, hierarchy, and copy are unchanged; the visual difference is the four-tab Liquid Glass tab bar only. Both images were captured through the suite's kept attachments, exported with `xcrun xcresulttool export attachments`, and reviewed directly before approval

GOLDEN-CHANGE (2026-09-05): all four existing references were recaptured and `activity-light.png` was added. The Showcase became a browsable catalog: every block now opens from the Blocks tab as a pushed detail screen with an inline navigation title, a one-line description above the block, and the four-tab Liquid Glass bar (Components, Blocks, Recipes, Tune) instead of the previous five block tabs. The block content, hierarchy, and copy are unchanged, and the accent is the Indigo theme applied once at the catalog root. The activity reference shows the Stage 3 feed in its loaded state: the Card delivery delayed notice with Dismiss, the Recent section with the unread Mishmash Bakery row, Salary received, and Statement ready. All five were captured through the suite's kept attachments, exported with `xcrun xcresulttool export attachments`, and reviewed directly before approval. This closes the open deferral about the fifth Components tab

GOLDEN-CHANGE (2026-09-05): `command-light.png` was added for the Stage 4 block. It shows the pristine light-mode screen on the pinned iPhone 17 iOS 27.0 runtime: the Search title, the empty search field with its magnifying glass, the Actions section (New transfer with its command-T keycap, Freeze card, Download statement), the Recent section (Mishmash Bakery, Salary), and the top of the shortcut legend. Captured through the suite's kept attachment, exported with `xcrun xcresulttool export attachments`, and reviewed directly before approval

## Item captures

Per-item light and dark images under `docs/images/items/` and the preset images under `docs/images/themes/` are documentation captures produced by `Scripts/capture_previews.py` from the Showcase's `-item` launch on the same pinned simulator. They feed the catalog and the website (copied into `Website/public/images/` by the site-data generator) and are human review evidence, not test baselines

GOLDEN-CHANGE (2026-09-05, threshold): the comparison moved from 96 by 192 at 2 percent to 192 by 384 at 1.5 percent so a whole tab bar or navigation bar can no longer hide inside the tolerance. All five references passed at the new setting without recapture

## Updating a reference

Do not regenerate a reference merely because a test failed

1. Inspect the failure attachment and identify the intended product change
2. Run the full UI suite on the pinned runtime
3. Export kept attachments from the resulting `.xcresult` with `xcrun xcresulttool export attachments`
4. Replace only the affected reference
5. Review the image directly
6. Record a `GOLDEN-CHANGE` note describing the intended visual difference

A threshold change is a visual-contract change and needs the same review

## Limits

The normalized comparison is deliberately small and deterministic. It can miss a subtle glyph-only change, so visible copy and accessibility semantics also have explicit UI assertions. Current-platform iPhone and iPad screenshots under `docs/images/` remain human review evidence, not test baselines
