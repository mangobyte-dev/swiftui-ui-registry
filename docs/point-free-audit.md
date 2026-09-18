# Point-Free audit

A disciplined pass applying Point-Free's functional-programming, modularization, ergonomics, and
testability ideas to the registry, where they actually apply. Not a rewrite: two passes of small
commits, each one principle, each proven by build + `swift test` + `validate` before moving on.

## Scope note (Rule 0: cite, don't assume)

- **"point-free-evolution"** is a local Obsidian vault at `~/Projects/point-free-evolution/`: a
  per-episode knowledge base for Eps 0 to 371 (375 raw transcripts, 45 arc files, 197 blog posts,
  mirrors of every Point-Free repository). The first pass searched the web only, missed it, and
  wrote that no such resource exists; that sentence was wrong. The second pass below reads the raw
  transcripts, and every `Ep N` quote in it was copied from `transcripts/NNNN-slug.txt` and checked
  back with `grep -F` (92 quotes, 0 misses).
- **"lazystate"**: confirmed as `pointfreeco/swiftui-lazy-state`, the `@LazyState` macro, v1.0.0,
  Xcode 27+/iOS 17+ (READMEs fetched directly this session). Fixes wasted allocation when a `@State`
  property needs a parameterized initializer.

## Method

First pass: one workflow, 9 parallel Opus 4.8 agents, one per topic cluster below, working from the
`pfw-*` skills and the libraries' manifests. Each agent did Phase 1 (research, real cited source) and
Phase 2 (repo audit, real file:line citations) together in one pass, because most of Point-Free's
toolkit turned out to already be in use here: this was a gap audit more than a greenfield one.

Second pass: one workflow, 16 parallel Opus 4.8 readers, one per cluster of raw transcripts (72 KB
to 255 KB each) plus the matching arc files and blog posts, each judging every principle against the
code and checking the first pass's claims. Three of those claims were refuted and are corrected in
place below, each marked **corrected**.

Every finding is backed by a file:line citation or a quoted primary source; "already applied, no
change" is reported as a real finding, not silently dropped, per the task's own instruction to say
when something doesn't apply.

## First pass: principle index and repo audit, by topic

### 1. Modularization (feature modules, package targets, minimal dependencies)

| Idea | Source | Verdict | Current state | Priority |
|---|---|---|---|---|
| One-way, acyclic target graph, no accidental cross-boundary imports | Point-Free's own manifests; `docs/architecture.md` | **applies, confirmed clean** | `Package.swift:30-59`; RegistryKit's only `import SwiftUI` hit is a string literal it emits (`Preset.swift:347`) | skip |
| Every target declares the external products it actually imports | Point-Free manifests declare every import explicitly | partially_applies | `SwiftUIRegistryCLI` used `@Dependency` without declaring the `Dependencies` product, relied on transitive resolution via RegistryKit | **done** |
| Core-vs-platform-optional split (shallow contract + opt-in UI product) | swift-sharing/swift-composable-architecture manifests | **applies, confirmed clean, better than the comparison libraries** | `SwiftUIRegistryFoundations` (0 deps) + `SwiftUIRegistryDesignSurface` (`#if canImport(UIKit)`, inert in release) already is this split | skip |
| Speculative sub-split of DesignSurface into core/UI targets | AGENTS.md "2 concrete consumers" rule | does_not_apply | No third consumer for a UIKit-free token model, RegistryKit already owns its own SwiftUI-free preset codec | skip |
| Macro target / TestSupport product patterns | swift-dependencies manifest | does_not_apply | No macros in this repo; the one test helper has a single consumer | skip |
| One test target per production target | swift-dependencies/TCA test-target split | partially_applies | `RegistryKitTests` tests both `RegistryKit` and `SwiftUIRegistryCLI`, defensible given the CLI's size (844 lines) | not done (churn > value) |

### 2. The Dependencies library (swift-dependencies)

| Idea | Source | Verdict | Current state | Priority |
|---|---|---|---|---|
| Tests must enter `.test` `DependencyContext` explicitly under Swift Testing (unlike XCTestCase, it's never auto-inferred) | `Dependencies.swiftinterface`, pfw-dependencies skill | **applies** | Test target linked no `DependenciesTestSupport`; no `.dependencies` trait, the throwing `testValue`s already written for network/archive/tags keys were dead code | **done** |
| Effectful `DependencyKey`s should have an explicit `testValue` so a forgotten override fails/throws instead of silently reaching `liveValue` | pfw-dependencies skill | partially_applies | **corrected**: there are 8 custom keys, not 7; the first pass never listed `RegistrySourceKey` (`FileSystem.swift`), whose live value walks the disk and then fetches the release snapshot. 3 of 8 had a throwing `testValue` (network/archive/tags); `RegistryInputKey` and `SourceMergerKey` got one in the first pass | **done** in two steps: input and merger in the first pass; file system and registry source in the second (see V1 below). `RegistryConsoleKey` alone keeps its live value: it prints, and the `command` helper always captures it |
| `@DependencyClient` macro to synthesize the 6 hand-rolled struct-of-closures clients | DependenciesMacros.swiftinterface | applies | All 6 clients are the exact shape the macro targets | not done, adds a macro dependency + refactors 6 types for modest gain on a working tool |
| Over-application check: `@Dependency` should wrap only real effects | pfw-dependencies skill + Rule 5 | **does_not_apply, confirmed clean** | Every site is a real effect (disk/network/process/stdio/uuid/clock); the seeded `PythonRandom` generator correctly has none | skip |
| App-entry `prepareDependencies` bootstrap | pfw-dependencies skill | does_not_apply | Nothing is constructed from a runtime secret; ambient `liveValue` in the live context is already correct | skip |

### 3. @Shared / the Sharing library

| Idea | Source | Verdict | Current state | Priority |
|---|---|---|---|---|
| Persisted state via `@Shared` with a typed `SharedKey` default, `.withLock` mutation, `.loadError` decode handling, tested via `withDependencies { $0.defaultFileStorage = ... }` | pfw-sharing skill | **applies, already realized to the canonical letter** | `.designTokens`/`.designKnobs` (`DesignTokens.swift`, `KnobStore.swift`) match the skill's exact pattern; tests already use Sharing's own test utilities | skip |
| `.appStorage` for state persisted/reset from outside a view, vs. view-bound `@AppStorage` | pfw-sharing skill | partially_applies | Panel geometry uses `@AppStorage` with keys centralized via `PanelGeometry.storageKey`; the button's two keys were duplicated string literals across two files, a latent bug if one changed | **done** (minimal fix: named the keys once; did not do the fuller `@Shared(.appStorage)` migration, `@AppStorage` is idiomatic for view-local geometry, only the duplication was the real defect) |

### 4. Observation & modern SwiftUI + `@LazyState`

| Idea | Source | Verdict | Current state | Priority |
|---|---|---|---|---|
| `@LazyState` for a `@State` model built from external init parameters | `pointfreeco/swiftui-lazy-state` README (fetched) | **does_not_apply** | Zero `State(wrappedValue:)` sites anywhere in the repo, the exact scenario the macro targets doesn't occur. Legitimate library, no consumer here | skip |
| Derive bindings via `@Bindable` + dynamic member lookup / subscript, never `Binding(get:set:)` | pfw-modern-swiftui skill ("NEVER use Binding.init(get:set:)") | **applies** | `FloatingTuneButton` hand-rolled two bindings with `Binding(get:set:)`, the cited anti-pattern. **corrected**: the first pass called the class removed; its sibling `DesignSurfaceOverlayRoot` still hand-rolled the selection binding over the same observable state | **done** in two steps (button in the first pass, overlay root in the second, V2 below). The remaining `Binding(get:set:)` sites are not this anti-pattern: the knob slider in `TuningPanel` and the three `Toggle`s in `Examples/TodoCounter` bind a value plus an action closure with no projected binding to derive from |
| View-local navigation `@State` ownership/naming | pfw-modern-swiftui skill | does_not_apply (for this topic) | `TuningPanel`'s `path: [String]` is already idiomatic ownership/naming; the domain-modeling question (should it be typed) belongs to topic 5 | skip here |

### 5. Enum-driven navigation and domain modeling + CasePaths

| Idea | Source | Verdict | Current state | Priority |
|---|---|---|---|---|
| Replace stringly-typed `status: String` with enums for exhaustive, typo-proof switches | pfw-swift-navigation skill (enum-over-stringly-typed) | **applies** | `Installer.FileStatus.status` and `Inventory.File.status` were `public var status: String` across 3 disjoint vocabularies (plan/update/inventory) sharing types, with 2 magic-string filter sites and zero compiler protection | **done, flagged as a public API change first, approved by owner before implementing** |
| Enum `Destination` for `TuningPanel`'s `NavigationStack(path:)` | pfw-swift-navigation / pfw-case-paths skills | **does_not_apply** | Destinations are registered at *runtime* by the consuming host app (`hostPage: (String) -> View?`), a package product can't enumerate a host's pages at compile time, so no closed enum is possible. `[String]` is the correct type across this plugin boundary | skip |
| `@CasePathable`/case key paths on the `JSON`/`OrderedJSON` enums | pfw-case-paths skill | partially_applies | The pattern fits the shape, but `grep 'if case' Sources/RegistryKit` returns only the 6 already-centralized accessor lines, zero scattered extraction to DRY up. Would add a dependency to the SwiftUI-free engine for marginal gain, and can't cleanly reproduce `OrderedJSON`'s nested-case accessor | not done, recommend against |

### 6. IssueReporting

| Idea | Source | Verdict | Current state | Priority |
|---|---|---|---|---|
| `reportIssue`/`withErrorReporting`: log-and-continue in production, hard-fail in debug/test | pfw-issue-reporting skill | **partially_applies (corrected)** | The production log-and-continue half does not apply: a dev CLI has no shipping runtime to protect, and typed errors fail loud at the CLI boundary (`Validation.swift`, `Main.swift`). The test half does: `reportIssue` is how a non-throwing member of an unimplemented test default fails by name (Ep 139, Ep 206), which is exactly what the first pass said a `FileSystem` stub could not do | **done** for the file system's six query members (V1 below); nothing else |
| Convert the sole `try!` (a compile-time-constant MCP tools JSON literal) | pfw-issue-reporting skill | does_not_apply | No recovery value exists; `withErrorReporting` would return `nil` tools, strictly worse | skip |
| Soften internal-invariant force-unwraps (`items[name]!`) | pfw-issue-reporting skill | does_not_apply | All are controlled-input invariants in dev-CLI codepaths where a crash is the intended loud failure; user-authored data is already guarded upstream by `Validation.swift`'s typed issues | skip |

### 7. Testing: `@Suite`/`@Test` traits, dependency control

| Idea | Source | Verdict | Current state | Priority |
|---|---|---|---|---|
| A single base suite other suites extend, inheriting its traits | pfw-testing skill | partially_applies | `Commands` is already a de-facto base suite (~10 files extend it via `extension Commands`), but that scope was invisible from the bare declaration | **done** (doc comment added in the same edit as the `.dependencies` trait) |
| Exhaustive-by-default dependency overrides | pfw-dependencies skill | **applies (corrected)** | The first pass wrote that no live dependency could silently leak. False: a `DependencyKey` that declares only `liveValue` gets it as its test value too, so `registryFileSystem` and `registrySource` reached the real disk and the release snapshot in any test without `withFixture`. True after V1 for both; `registryConsole` still prints | **done** (V1) |
| Hoist repeated overrides onto the base suite via `.dependencies { }` | pfw-testing skill | partially_applies | Fixed-clock/git-merger overrides repeat across 3 harness helpers; centralizing is a legitimate but marginal ergonomics call, the current explicit form is arguably clearer for a test harness | not done, flagged as optional |
| Add `.timeLimit`/`.tags`/`.disabled`/`.bug` traits | swift-testing native traits | does_not_apply | No open defect to tag, suite is sub-second, whole-suite run in CI, would be scope creep | skip |

### 8. Snapshot testing of views (swift-snapshot-testing)

| Idea | Source | Verdict | Current state | Priority |
|---|---|---|---|---|
| `assertSnapshot(of: view, as: .image(...))` for automated per-item dark-mode/Dynamic-Type regression testing | pfw-snapshot-testing skill | partially_applies | Real gap: today, per-item dark/Dynamic-Type variants are reviewed manually (`docs/visual-testing.md` calls the captures "review evidence, not baselines"). But this would add a second image-golden corpus needing its own `GOLDEN-CHANGE` discipline, risk flakiness on Liquid Glass render content, and needs a new test-target dependency (`RegistryKitTests` is SwiftUI-free by contract; only `SwiftUIRegistryShowcaseFeatureTests` has an iOS host) | **recommended only, not applied**: risk was scored medium by the audit itself; expanding a deliberate, human-reviewed testing contract needs a named defect driving it, not a nice-to-have |

### 9. IdentifiedCollections + TCA integration boundary

| Idea | Source | Verdict | Current state | Priority |
|---|---|---|---|---|
| TCA/IdentifiedArray are application-logic libraries; they belong in consumer/app code, never in a source-owned UI library | pfw-composable-architecture skill + AGENTS.md Rules | **does_not_apply inside the registry, confirmed clean boundary** | `grep 'ComposableArchitecture' Sources/ Registry/sources/` → zero matches. TCA appears only in `Examples/TodoCounter`, the documented second consumer | skip |
| `IdentifiedArray` for `Registry.items`/`Inventory.items` | pfw-identified-collections skill | **does_not_apply** | `Registry.items` is already a `[String: JSON]` dictionary (O(1) by name); `Inventory.items` is a plain `[Item]` built once and only ever iterated, never looked up by id, and `Item` isn't even `Identifiable`. Converting either would add a dependency for zero measurable gain | skip |

## Second pass: vault-sourced principles

Sixteen transcript clusters, 92 principles judged: 51 already applied, 21 that do not apply to a UI
library or a CLI, 16 partially applicable, 4 applicable. The applied and recommended ones follow. Priority is gain (testability plus ergonomics, 0 to 5) over
churn (1 to 5). Every quote is verbatim from the raw transcript; every current-state claim names the
file and line it was read at.

### Applied (V1 to V5)

| # | Idea | Source | Current state before | Change | Risk | Touches | Priority |
|---|---|---|---|---|---|---|---|
| V1 | An effectful dependency's test default fails loudly and by name; a member that cannot throw reports an issue and returns an obviously broken value | Ep 139: "instead of doing a fatalError inside each endpoint of our dependency we put in a XCTFail". Ep 310: "We can make this explicit by reporting an issue before returning the database:" | `FileSystemKey` and `RegistrySourceKey` declared only a `liveValue` (`Sources/RegistryKit/FileSystem.swift`), so a test without `withFixture` read the real disk and fetched the release snapshot | `UnimplementedFileSystem` as the test value: six throwing members throw `RegistryError`, six queries call `reportIssue` and answer as an empty disk; `UnimplementedRegistrySource` throws. `IssueReporting` declared for `RegistryKit` (already resolved at 2.1.0 through swift-dependencies). Two tests in `TestDefaultsTests.swift`, one of which proves the live path would have succeeded | low | RegistryKit, Package.swift, tests | 3/2 |
| V2 | Derive a binding from the model's projection, never `Binding(get:set:)` | Ep 215: "The $model variable is of type ObservedObject.Wrapper, which is a type vended by SwiftUI, and it does not have a property named destination." | `DesignSurfaceOverlayRoot` held `private let state` and a `selectionBinding` computed from `Binding(get:set:)` (`DesignSurfaceWindow.swift:126,146,187-189`) | `@Bindable private var state`, pass `$state.selection`, delete the computed binding | low | DesignSurface | 2/1 |
| V3 | One optional or one owner for a presentation's data, not parallel fields that must be reset by hand | Ep 4: "There are a lot of representable states here that don't make sense." Ep 370: "It seems we are yet again back to two pieces of state to describe our alert" | `TuningPanel` held `isImporting`, `importText`, `importFailed` (`TuningPanel.swift:20-22`) for one `.sheet(isPresented:)` (line 125); `beginImport` reset the trio; a failure outlived the sheet | The sheet owns the draft and its failure as transient `@State` and calls `apply: (String) -> Bool`; the panel keeps `isImporting` alone. `ImportDraft?` with `.sheet(item:)` was the alternative; it hands the sheet a value, not a binding, so a two-way draft would need `Binding(_:)` unwrapping for the same result. The import UI test passed on the pinned simulator | low | DesignSurface | 2/2 |
| V4 | Compare large values with a structural diff, not a flattened dump | Ep 324: "a modern test suite will get more mileage out of using our expectNoDifference function for comparing large data structures than the #expect macro". Ep 220: "The error message is a total mess. I have absolutely no idea what is different between these two values." | 316 `#expect(==)` in `Tests/`, zero `CustomDump`; the multi-field ones: resolved closures (`RegistryContractTests.swift:52,260-273`), a full receipt (`:406`), a JSON array (`:486`), preset tunings (`PresetTests.swift:26,29`), and whole generated files as `Data` (`GeneratorTests.swift:107`), which named the drifting file but not the line | `CustomDump` linked to `RegistryKitTests` only (already resolved at 1.7.3); those sites use `expectNoDifference`; the drift guard diffs text and keeps byte equality for images. Scalars stay on `#expect` | low | tests, Package.swift | 3/2 |
| V5 | Redaction covers appearance and interaction; an effect the content starts itself still runs | Ep 115: "that logic would still execute just like normal, even if the whole view is disabled" | `RegistrySkeletonModifier.swift:35-40` redacts, disables, blocks hit testing, and hides from accessibility; the doc comment promised "no interaction" and said nothing about `task` or `onAppear` inside the content | One sentence in the doc comment naming the consumer's part; skeleton 0.2.1 to 0.2.2, reinstalled into the Showcase, generators rerun. The blocks that use it already honor the boundary (`SkeletonLoading.swift:41-48` passes empty actions) | none | copy-owned source, Showcase, generated | 2/2 |

### Recommended, not applied

| # | Idea | Source | Current state | Proposed change | Why not now | Priority |
|---|---|---|---|---|---|---|
| R1 | A protocol with one or two conformances is a struct of closures in disguise; a witness struct gets `unimplemented` for free | Ep 34: "Pretty much any protocol can be turned into an explicit struct." Ep 110: "A protocol that only has two conformances is not a strong form of abstraction." | `FileSystem` (12 requirements, 2 conformances) and `RegistrySource` (1 requirement, 3 conformances) were the two protocol dependencies; the other six are structs of closures (`Console.swift:6`, `RegistryInput.swift:5`, `ReleaseSnapshot.swift:19,46,78`, `SourceComparison.swift:12`) | **Applied as V6 after the owner's yes**: both are `public struct`s of closures with `.local` and `.unimplemented` values; `write(_:to:)` and `repositoryRoot(override:refresh:)` stay as methods over the closures so no `@Dependency` call site moved; the test doubles became values (`InMemoryFileSystem.fileSystem`, `RegistrySource.inMemory`, an inline source over the repository root) | Public API change, approved 2026-09-18 | 3/4 |
| R2 | Phantom-typed identifiers so an item name cannot be passed where a path belongs | Ep 12 (Tagged) | Item names, receipt keys, and paths are `String` throughout `Installer.swift:40-136`, `Registry.swift:34`, `MCPServer.swift:164`. The name is always the sole unlabeled first argument and `destination:` is labeled, so no silent swap compiles. The only unlabeled same-type pairs are path-to-path (`FileSystem.replace`, `safeJoin`) which `Tagged` would not separate | A five-line `ItemName` newtype, no dependency | **Declined by the owner 2026-09-18.** No mix-up site found | 1/4 |
| R3 | Build a value in one expression, not a `var` mutated by a run of statements | Ep 7: "We don't have to create lots of temporary, throwaway variables that we must mutate in statements to get the final value" | `ThemeTuning.exactTheme` (`ThemeTuning.swift:344-370`) assigns seven fields after `RegistryTheme(...)` although the initializer accepts each | Move the seven assignments into the initializer call | `exactSwiftSource` (`:444-475`) deliberately emits the same statement shape so the runtime theme mirrors the Swift a consumer pastes; collapsing one side alone makes them diverge | 1/3 |
| R4 | Enable a library's deprecations trait before its next major | Blog 2026-03-16: enable the `ComposableArchitecture2Deprecations` trait | `Examples/TodoCounter/TodoCounterPackage/Package.swift:19` pins TCA `from: "1.26.2"` with no `traits:` | Add the trait to the example's dependency and fix what it flags | The example is not in the verification list, and the registry itself is unaffected; do it when TodoCounter is next touched | 1/2 |
| R5 | Assert on one subject as image plus separate semantic checks; per-item dark and Dynamic Type image snapshots | Ep 38: "It captured the removal of the view! This is state that the image-based snapshot would not have accounted for." | Already the shape of the Showcase UI tests: committed PNGs compared at 1.5 percent (`SwiftUIRegistryShowcaseUITests.swift:1044-1091`) beside semantic `XCTAssert`s; the 33 `assertInlineSnapshot` sites in `Tests/RegistryKitTests` are all `.lines` text | Per-item `.image` snapshots for dark and accessibility sizes | Unchanged from the first pass: a second golden corpus and Liquid Glass flakiness; needs a named defect | 1/3 |
| R6 | Snapshot a large typed value with `.customDump` so a change re-records | Ep 324: "This test still fails, but now it's actually understandable what is wrong" | The receipt at `RegistryContractTests.swift:406` now uses `expectNoDifference` (V4) | `assertInlineSnapshot(of: record(), as: .customDump)` | Either or with V4 for the same site, and Ep 324 itself flags the cost: the expected value leaves the call site | 2/2 |
| R7 | `@DebugSnapshot` for exhaustive testing of an `@Observable` class | Blog 2026-05-27 (DebugSnapshots public beta) | `DesignSurfaceState` is the only `@Observable` class in `Sources/` (`DesignSurfaceState.swift:9-12`), a `@MainActor` singleton | Adopt when the library leaves beta and a second observable model exists | Beta dependency; AGENTS.md's dependency rule | watch |

### Confirmed applied, no change

| Idea | Source | Where |
|---|---|---|
| Validation accumulates every issue instead of throwing on the first | Ep 20 (applicative validation) | `RegistryValidator.validate` returns `[ValidationIssue]` (`Validation.swift:15,19,82`); `load()` reports read and parse failures as issues (`:95-107`) |
| A seeded generator takes its randomness as an input | Ep 48: "by taking the dependency up front as an input argument of the wrapped function, we were able to recover testability without sacrificing composability" | `PythonRandom` is CPython's MT19937 (`PresetRandom.swift:7-66`); `\.uuid` only on the seedless branch (`:90-95`); golden `--seed 3` snapshot (`PresetTests.swift:59-66`) |
| Styles as composable appearance units, a grid vocabulary, a separate style-guide framework | Ep 3, Ep 17: "This is all reusable code! That means it's code that we should extract into its own style guide file or framework!" | `RegistryMetrics` (`RegistryTheme.swift:126-160`); `SwiftUIRegistryFoundations` with zero dependencies (`Package.swift`); the `registry`-prefixed styles themselves are copy-owned in `Registry/sources/components`, not in Foundations |
| Leading-dot static witnesses | Ep 35 | `extension ButtonStyle where Self == RegistryButtonStyle { static var registry }` (`RegistryButtonStyle.swift:63-69`) |
| A plain `Bool` is right for a static presentation; one optional item for data-driven ones | Ep 160, Ep 161 | The `alert-dialog`, `dialog`, `popover`, `drawer`, `sheet` recipes present static content from one `Bool`; `toast` takes `Binding<RegistryToast?>` (`RegistryToastModifier.swift:68-80`). iOS 27's `alert(_:item:)` has no adopter here and would need an availability fence above the iOS 26 floor |
| Thin app target, fat feature package, a preview app per feature | Ep 171: "all the real code of the project lies in one of 7 SPM modules." | `SwiftUIRegistryShowcaseApp.swift:6-32` and `TodoCounterApp.swift:4-11` only launch a package view; `-item <name>` renders one item alone (`ContentView.swift:20-21`) |
| Value types with data equality, reference types never `Equatable` by data | Ep 297, Ep 299 | No class in `Sources/` conforms to `Equatable` or `Hashable`; item reports are keyed by a value-type `UUID` (`RegistryItem.swift:24`, `DesignSurfaceState.swift:55`) |
| Per-type `@MainActor`, `nonisolated(nonsending)` upcoming feature, `Mutex` where nothing is lent out of the lock | Ep 365, Ep 369: "default main actor isolation doesn't really carry its weight" | `Package.swift` enables `NonisolatedNonsendingByDefault` on the engine, CLI, and their tests (inert today: no `async` in either); `Mutex` at `RegistryInput.swift:11` and `ReleaseSnapshot.swift:24`; no `defaultIsolation` anywhere |
| A typed `SharedKey` bundling key, type, and default; `withLock` mutation; a corrupt file keeps the shipped default and surfaces the error | Ep 306: "It encapsulates the string-y key, the type of data stored, and even the default value." Ep 308 | `.designTokens` (`DesignTokens.swift:5-20`), `.designKnobs` (`KnobStore.swift:38-49`), `withLock` (`KnobStore.swift:72,83`), `loadError` (`TokenDocument.swift:132-139`), tested through `$0.defaultFileStorage` (`SurfaceBoundaryTests.swift:100-119`) |
| Test a CLI by snapshotting stdout over an in-memory file system that records installs and links | Ep 354 | `InMemoryFileSystem.swift`, `CommandSupport.swift`, `PresetCommandSnapshots.swift` |
| Extractors as optional computed properties; no scattered `if case` | Ep 257: "Enums don't have getters and setters, they instead have 'extractors' and 'embedders.'" | 9 `if case` lines in `Sources/RegistryKit`, all inside the `JSON` and `OrderedJSON` accessors or the MCP argument decoder; `@CasePathable` would DRY nothing |
| An `@Observable` model outside the view; no `withObservationTracking`; no init-time reads | Ep 252 to 256 | `DesignSurfaceState` is the one `@Observable` (`DesignSurfaceState.swift:10`), `private init()` reads nothing observed (`:107`); zero `ObservableObject`, `@Published`, or `withObservationTracking` in `Sources/`, the Showcase, or `Registry/sources` |
| No custom operators; composition through named modifiers | Ep 11: "Operators shouldn't be the bottleneck to introducing composition to your code" | No `infix operator` or `prefix operator` in `Sources` or `Registry` |
| Deterministic tests without sleeps or yield loops | Ep 238, Ep 241 | No `async` test function, no `Task.sleep`, no `Task.yield` in `Tests/`; the Showcase UI tests wait on `waitForExistence` |

### Does not apply, and why

| Idea | Source | Reason |
|---|---|---|
| Redact a feature's logic by swapping a no-op reducer and empty dependencies | Ep 116, Ep 117 | A copy-owned UI library has no reducer or store; the skeleton item's appearance boundary (V5) is the whole of what transfers |
| Interface and live implementation in separate modules to keep a heavy SDK out of previews | Ep 111, Ep 207, Ep 292 | No dependency here wraps a heavy SDK; the live values are `FileManager`, `Process`, and `URLSession` |
| Cross-platform core without Apple frameworks | Ep 292, Ep 296 | `Installer.swift:1` imports `CryptoKit` for SHA256 (`:263,266`); AGENTS.md sets no cross-platform goal. `swift-crypto` would be the route if that changed |
| `NonEmpty` in the type | Ep 19 | Every collection here (closures, children, issues) is legitimately empty at times |
| Hidden singletons audit (`Bundle`, `UIScreen`, `Locale`, `Calendar`) | Ep 18 | The only ambient reads are `FileManager` and process I/O, already behind `@Dependency` |
| `unimplemented()` as a parent-child callback default | Ep 216 | The design surface's host hooks (`DesignSurfaceState.swift:24-33`) are optional because a host legitimately supplies none |
| A `Route` enum for mutually exclusive presentations | Ep 164 | The design surface has exactly one presentation (`TuningPanel.swift:125`); `TuningPanel`'s destinations are host-registered at runtime, so no closed enum exists |
| SwiftPM traits to stage a major release | Blog 2026-03-16 | The registry pins swift-sharing `2.9.1..<2.10.0, traits: []` (`Package.swift`) and ships no trait of its own; revisit at 1.0 (see R4 for the example app) |
| `~Copyable` and `~Escapable` around a precious mutable resource; `@FetchAll` in feature state; TCA 2.0's `@Feature` and `Update` | Ep 354 to 356 | No raw pointer, database, reducer, or store exists in the registry; TCA lives only in `Examples/TodoCounter` (TCA 1.26.2) |
| `UIKitNavigation`'s `observe` and transactions | Ep 371 | The design surface's UIKit is window chrome (`DesignSurfaceWindow.swift:19,90`), a pasteboard, and a dynamic color; observation is SwiftUI's |
| Key-path synthesis for setter-only framework APIs | Ep 17 | SwiftUI modifiers already return values |

## Phase 3: what changed (one principle per commit)

First pass:

| Commit | Principle | Touches | Risk |
|---|---|---|---|
| `b9c73a7` | Declare the `Dependencies` product for `SwiftUIRegistryCLI` explicitly | Package.swift | none |
| `2996b00` | Run the command/CLI test suite in Dependencies' `.test` context (+ name `Commands` as the base suite) | Package.swift, 2 test files | low |
| `ec3e667` | Give `RegistryInputKey`/`SourceMergerKey` throwing `testValue`s | RegistryKit | low |
| `24607d5` | Derive `FloatingTuneButton`'s bindings without `Binding(get:set:)` | DesignSurface | low |
| `d15d9a5` | Name the button's `AppStorage` keys once instead of duplicating literals | DesignSurface | none |
| `ea81f96` | Replace stringly-typed file statuses with enums (wire-preserving) | RegistryKit, CLI, tests | low, **public API change, flagged and approved before implementing** |

Second pass:

| Commit | Principle | Touches | Risk |
|---|---|---|---|
| `18af421` | Regenerate the site changelog copy the first pass left stale (its `Unreleased` entry failed `generatedOutputsMatchCanonicalBytes`) | generated | none |
| `14e7d76` | V1: fail loudly when a test reaches an un-overridden file system or registry source | RegistryKit, Package.swift, tests | low |
| `ab44ea2` | V2: derive the overlay root's selection binding from `@Bindable` | DesignSurface | low |
| `306fb80` | V3: keep the import draft and its failure inside the import sheet | DesignSurface | low |
| `d94e427` | V4: diff multi-field test values with `expectNoDifference` | tests, Package.swift | low |
| `2907402` | V5: record that the skeleton gates appearance and interaction, not effects | copy-owned source, Showcase, generated | none |
| `4a7b803` | Dogfood F2: declare the state the `field` usage snippet reads | metadata, generated | none |
| `0f686bc` | V6: `FileSystem` and `RegistrySource` as structs of closures | RegistryKit, tests | low, **public API change, approved before implementing** |
| `b4b663c` | Dogfood F1, F4, F7: shop vocabulary aliases on 13 items, `toast` shows `message:`, `carousel` names its placeholder | metadata, generated | none |
| `6871db5` | Dogfood F5: `describe` lists public signatures, in text and in the JSON and MCP payloads | RegistryKit, CLI, tests | low, additive payload field |
| `90c22e3` | Dogfood F6: a names search that matches nothing says so | CLI, tests | none |
| `dabb739` | The consumer skill documents `Signatures:` and the no-match message | Skills | none |
| `dafc7ca` (merges `6a6d651`) | Dogfood F2 gate: `generate usage-checks`, the fifth generator, plus the placeholder file, CI, AGENTS, and docs | RegistryKit, CLI, Showcase, tests, docs | low |
| `4f253ab` | Dogfood F2: four block snippets declare their state, the gate compiles all 48 | metadata, generated, Showcase | none |

V6 is the one second-pass commit that changes public API, and it followed the owner's answer. V5 is the one edit to `Registry/sources/`: a doc comment,
with the item's patch version bumped and the Showcase copy reinstalled. Two manifest lines were
added, both for packages already in `Package.resolved` (no resolution change): `IssueReporting` for
the engine's test default and `CustomDump` for the test target only.

## Phase 5: dogfood findings

A fresh agent built an e-commerce front end (`~/Projects/ShopFront`: product list, detail, cart,
checkout, mock data) from the released `swiftui-registry` 0.3.1 and the spec's "Agent usage" steps,
seeing no registry source. 14 items installed, 3 recipes used as guidance, build clean, four
screens verified on the pinned simulator. Each finding below was checked against the registry
afterwards.

| # | Step | Finding | Severity | Status |
|---|---|---|---|---|
| F1 | search | `product`, `cart`, `price`, `checkout`, `quantity`, `rating`, `stepper`, `price-tag` all return nothing; no item's name, tags, or aliases carry any of them. The fitting items (item, field, badge, toast, empty) are reachable only by internal name | major | **fixed** (`b4b663c`): thirteen items gained shop aliases; `product`, `cart`, `price`, `checkout`, and `rating` now resolve |
| F2 | compose | `field`'s usage snippet used `$name` and `emailError` without declaring them, so it did not compile as printed. The gate then found the same defect in `auth-form`, `signup-form`, `message-scroller`, and `settings-section` | major | **fixed** (`4a7b803`, then the gate commit): all five declare their state; `generate usage-checks` now compiles every installable snippet in the Showcase |
| F3 | compile | The XcodeBuildMCP scaffold pairs `swift-tools-version: 6.1` with `.iOS(.v26)`; the first added dependency fails resolution | major | scaffold defect, not the registry's; bumped to 6.2 in the app |
| F4 | docs | `toast`'s snippet omits `message:` (`RegistryToastModifier.swift:46` has it) | minor | **fixed** (`b4b663c`) |
| F5 | docs | `describe` shows call shape, not parameter types (`MetricCard`'s `LocalizedStringResource` title and `Text` value) | minor | **fixed** (`6871db5`): `describe` lists every public initializer, function, and static member under `Signatures:`, and the JSON and MCP payloads carry `signatures` |
| F6 | search | `--format names` prints nothing on zero matches; JSON prints `[]` | nit | **fixed** (`90c22e3`): stderr says `No item matches ...`, exit 0 |
| F7 | compose | `carousel`'s recipe snippet iterates an undeclared `cards` | minor | **fixed** (`b4b663c`): the snippet opens by naming `cards` as the consumer's model |

The compile gate exists now: `swiftui-registry generate usage-checks` writes one `View` per
installable item around its snippet (declarations as members, views in `body`, an assignment in a
method), and the Showcase build type-checks the file. Names a snippet leaves to the adopter are
stand-ins in `UsageSnippetPlaceholders.swift`. It is Ep 55's idea: save the generated code as a real
Swift file so the compiler validates it. Its first run found four more broken snippets. Missing components a shop wanted: a price display, a quantity stepper,
a rating, a product tile with an image; each was composed from badge, button, metric-card, and item.

## Owner decisions, 2026-09-18

1. **R1**, `FileSystem` and `RegistrySource` as structs of closures: yes, applied as V6.
2. **R2**, an `ItemName` newtype: no.
3. Dogfood proposals (shop-vocabulary aliases, a snippet compile gate): no at first, then "fix the
   weak points" later the same day, with the stated aim of using Point-Free's ideas to cut the
   friction an agent meets; all seven findings are fixed, see Phase 5.
4. **R4**, `ComposableArchitecture2Deprecations` on `Examples/TodoCounter`: deferred until that app
   is next opened.

## Deliberately not applied, and why

- **`@LazyState`**: legitimate library, zero consumers in this repo today (no `State(wrappedValue:)`
  parameterized-init pattern exists). Re-evaluate if a future view owns an `@Observable` feature model
  built from external parameters.
- **CasePaths on `JSON`/`OrderedJSON`**: would add a dependency to the SwiftUI-free engine to DRY up
  6 lines that are already centralized once, and can't cleanly reproduce `OrderedJSON`'s nested-case
  accessor. Recommend against.
- **IssueReporting in production paths**: a dev CLI has no production runtime; typed errors that
  fail loud at the boundary cover its domain. Its test-default use is applied (V1).
- **`IdentifiedArray`**: no keyed-lookup call site exists for either candidate collection; would add
  a dependency for no measurable gain.
- **Enum-driven `Destination` for `TuningPanel`**: the destination set is host-registered at runtime
  across a package/consumer boundary; no closed enum is possible here.
- **Per-item view-image snapshot testing**: real automation gap identified, but recommended only.
  Applying it would expand `docs/visual-testing.md`'s deliberate, human-reviewed golden-image contract
  and add real Liquid Glass flakiness risk; that trade deserves your explicit call, not an autonomous one.
- **`@DependencyClient` macro adoption, base-suite trait hoisting, splitting `RegistryKitTests`**: each
  reviewed and judged real-but-marginal: the churn (new macro dependency, or moving fixtures across ~10
  files, or renaming a test target) outweighs the ergonomics gain on a tool that already works.

## Phase 4: before / after

| Check | Before the first pass | After the first pass | After the second pass |
|---|---|---|---|
| `swift build` | clean, 0 warnings | clean, 0 warnings | clean, 0 warnings |
| `swiftui-registry validate` | passed: full catalog | passed: full catalog | passed: full catalog |
| `swift test` | **80/80** passed (8 Foundations, 72 RegistryKit) | **79/80**: `generatedOutputsMatchCanonicalBytes` failed on the stale site changelog copy (found at the start of the second pass, fixed in `18af421`) | **82/82** passed (8 Foundations, 74 RegistryKit), 1 known issue, which is the `withKnownIssue` in `TestDefaultsTests` proving the file system query reports |
| Generator drift (`git diff --exit-code -- docs/catalog Examples/Showcase Website/content .../RegistryItemTokens.swift`) | n/a | one stale file | **no drift** after every commit that touched metadata or the changelog |
| `make format-check` | n/a | clean | clean |
| Showcase simulator build | n/a | succeeded, 0 warnings | succeeded, 0 warnings, after each of V2, V3, and V5 |
| Showcase feature tests (`SwiftUIRegistryShowcaseFeatureTests`, scoped) | n/a | 54/54, 2 skipped (pre-existing) | 54/54, 2 skipped, plus the one import UI test (`testTuningPanelImportsAPastedThemeIntoTheKnobs`) run alone after V3: passed |
| Showcase full XCUITest UI suite (6-screen pixel-diff gate) | already failing on an unchanged tree per `CHANGELOG.md` 0.3.1 (4.0 to 5.5 percent against the 1.5 percent tolerance, all 6 screens) | hung 30 minutes with no output; not re-run | not run, by the owner's instruction; the six failures predate both passes |
