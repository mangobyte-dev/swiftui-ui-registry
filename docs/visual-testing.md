# Visual testing

## Contract

The showcase UI tests compare the finance and nutrition screens with approved references under `Examples/Showcase/SwiftUIRegistryShowcaseUITests/ReferenceImages/`

The contract is pinned to a light-mode iPhone 16 Pro running iOS 18.0. Native controls and tab presentation intentionally change across Apple platform versions, so a different runtime is visual review evidence rather than a valid baseline runner

## Comparison

`SwiftUIRegistryShowcaseUITests.swift`:

1. Captures the app through `XCUIApplication.screenshot()`
2. Removes the top 7 percent containing volatile status-bar content
3. Normalizes both images to 96 by 192 RGBA pixels
4. Computes mean absolute channel difference
5. Fails when the normalized difference exceeds 2 percent

Semantic UI assertions remain separate. The image check protects layout, hierarchy, surfaces, color distribution, and major typography without treating the changing clock as product output

## Approved references

- `finance-light.png`
- `nutrition-light.png`

GOLDEN-CHANGE: these initial references were approved after iPhone and iPad review of both domains, an iOS 18 deployment-floor run, and an accessibility-size run. Future reference changes require the same explicit note in the reviewing change

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
