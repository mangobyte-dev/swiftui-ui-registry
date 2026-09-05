# Handoff: audit the registry against SwiftUI best practice

Written 2026-09-05 at the end of the session that delivered Stages 3 and 4, the set-up-once foundations, the catalog Showcase with the Tune panel, the shadcn/ui website on Cloudflare, and the open-source readiness pass. Paste the block below into a fresh session in this repository. Current stage status and the backlog live in `docs/component-roadmap.md`; this file is a brief, not a second home for state

---

I am Mo, the owner of SwiftUIRegistry, a native-first registry of SwiftUI product UI in the spirit of shadcn/ui: 50 items (26 components, 6 blocks, 18 recipes) that a consumer copies into their app and owns, one small foundations package for the theme, a Showcase app, and a website. Everything is green as of commit `b404162`: validator, 91 Python tests, 5 package tests, an 18-test UI suite on the pinned iPhone 17 iOS 27 simulator, and the website build. Nothing is pushed yet

This session is an audit, not a feature session. Every registry item was written quickly and verified by tests and captures; none has been reviewed line by line against SwiftUI best practice. I want that review, and I want the fixes applied where the evidence is clear

## Load these before reading any code

1. `/uncle-bob-swarm`, if it is available in this session, to run the audit as a fan-out with a refuting verify phase; if it is not listed as a skill, do the same work serially and say so at the top of the report
2. `/pfw-modern-swiftui`: naming, correct binding and state initialization, modern API usage
3. `/swiftui-specialist`: Apple's own guidance; this supersedes training data on animation, `@Observable`, `ForEach` identity, environment and `@Entry`, localization, and soft-deprecated APIs
4. `/swiftui-pro`: the review checklist for maintainability and performance
5. `/swift-concurrency-pro` for anything touching `Task`, `MainActor`, or `Sendable` (the tuning panel and the auth harness use `Task`)

Loading a skill is not reading it. For every rule you apply, quote the rule and name the file and line it applies to

## Ground truth, in this order

1. `AGENTS.md` (rules, boundaries, the verification loop), then `docs/philosophy.md` and `docs/architecture.md`
2. `docs/component-roadmap.md`, Current state and Backlog, for what is done and what is deferred
3. `Sources/SwiftUIRegistryFoundations/RegistryTheme.swift`, the whole theme contract
4. `Registry/sources/components/` and `Registry/sources/blocks/`, the 32 canonical files. The copies under `Examples/Showcase/.../Installed/` are derived; never edit them directly
5. `Examples/Showcase/SwiftUIRegistryShowcasePackage/Sources/SwiftUIRegistryShowcaseFeature/` for the demos, `ThemeTuning.swift`, and `TuningPanel.swift`
6. `Tests/RegistryTests/test_installer.py` for the token-consumer contract and the structural pins that must keep passing

## What to audit, per item

Read each canonical file and judge it on four axes. Report a finding only with a file and line, the rule it breaks, and the concrete consequence

- Correctness: bindings and `@State` ownership (a component owns transient state only when no caller must coordinate it), `ForEach` identity, environment reads, focus handling, `onChange` usage, Dynamic Type, right-to-left, disabled state, and every accessibility claim in the item's `Registry/items/<name>.json` measured against the code. Two claims were already found false this session and fixed (text-field labels); assume others may be
- Performance and efficiency: body work that should be cached, `AnyShapeStyle` and `AnyView` where a concrete type would do, `ViewThatFits` and `Group(subviews:)` costs, redundant layout passes, animations that ignore Reduce Motion, `phaseAnimator` running when nothing is visible
- Modern API and soft-deprecations: anything the specialist skill flags, including `NavigationView`, the old `onChange`, `.animation()` without a value, string keys where `LocalizedStringResource` is the contract
- Architecture neutrality: no item may import or assume an app architecture, networking, persistence, or a state container. Prepared values in, bindings and closures out. If an item leaks a decision that belongs to the caller (validation, formatting, navigation, scrolling, maximum width), that is a finding

Also audit the foundations file itself: is `RegistryTheme` the smallest contract that still lets a consumer set up once? Is anything in it speculative?

## Rules that bind this session

- The Apple primitive stays visible at the call site. Do not introduce wrappers, a styling abstraction, or a token a second item does not need
- Surgical changes only. Fix the finding, keep the file's style, do not "improve" adjacent code
- A fix to a canonical file is followed by the loop in `AGENTS.md` Verification, scoped to the change: reinstall into the Showcase with `--force`, regenerate the catalog, the Showcase manifest, and the site data, run the Python tests, build, and run the UI suite if anything visible changed. Recapture an item with `python3 Scripts/capture_previews.py <item>` if its look changed
- Buttons and badges never wrap or break their labels. Text fields need an explicit `accessibilityLabel`; on iOS 27 no initializer supplies one. `labelsHidden()` drops the spoken label too. These are measured facts from this session, not opinions
- Do not read `UIPasteboard` from a UI test; it hangs the suite on the paste prompt
- Never regenerate a visual reference to make a test pass; follow `docs/visual-testing.md` and write a `GOLDEN-CHANGE` note when a change is intended
- Do not push, do not tag, do not deploy the website; commit locally with the attribution trailer the harness gives you
- No em dashes anywhere

## Deliverable

1. A findings table in the report and in `docs/component-roadmap.md` under a new dated "Audit" section: item, file and line, axis, rule quoted, consequence, and status (fixed in commit X, or deferred with the reason). Verified findings only; a verify pass must try to refute each one before it is listed
2. The fixes, one commit per item or per shared cause, each passing the scoped verification loop
3. A closing count that names what was skipped: which items were not read, which tests were not run, and why

Start with the blocks (`AuthForm`, `SettingsSection`, `ActivityFeed`, `CommandSearch`, `FinanceOverview`, `NutritionOverview`) because they compose everything else, then the components in dependency order from `python3 Scripts/install.py <block> --plan`
