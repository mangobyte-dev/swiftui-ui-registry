# Point-Free audit

A disciplined pass applying Point-Free's functional-programming, modularization, ergonomics, and
testability ideas to the registry, where they actually apply. Not a rewrite: 6 small commits, each
one principle, each proven by build + `swift test` + `validate` before moving on.

## Scope note (Rule 0: cite, don't assume)

- **"point-free-evolution"**: no resource by this exact name exists on pointfree.co, GitHub, or
  elsewhere (searched multiple phrasings). Treated as shorthand for "how Point-Free's own tools have
  evolved" and surveyed via their GitHub org manifests (`swift-dependencies`, `swift-sharing`,
  `swift-composable-architecture`), pointfree.co episodes, and the `pfw-*` skills (canonical local
  references for exact API usage).
- **"lazystate"**: confirmed as `pointfreeco/swiftui-lazy-state`, the `@LazyState` macro, v1.0.0,
  Xcode 27+/iOS 17+ (READMEs fetched directly this session). Fixes wasted allocation when a `@State`
  property needs a parameterized initializer.

## Method

One workflow, 9 parallel Opus 4.8 agents (well under the session's 20-agent cap), one per topic
cluster below. Each agent did Phase 1 (research, real cited source) and Phase 2 (repo audit, real
file:line citations) together in one pass, because most of Point-Free's toolkit turned out to
already be in use here — this was a gap audit more than a greenfield one. Every finding below is
backed by a file:line citation or a fetched primary source; "already applied, no change" is reported
as a real finding, not silently dropped, per the task's own instruction to say when something doesn't
apply.

## Phase 1 + 2: principle index and repo audit, by topic

### 1. Modularization (feature modules, package targets, minimal dependencies)

| Idea | Source | Verdict | Current state | Priority |
|---|---|---|---|---|
| One-way, acyclic target graph, no accidental cross-boundary imports | Point-Free's own manifests; `docs/architecture.md` | **applies — confirmed clean** | `Package.swift:30-59`; RegistryKit's only `import SwiftUI` hit is a string literal it emits (`Preset.swift:347`) | skip |
| Every target declares the external products it actually imports | Point-Free manifests declare every import explicitly | partially_applies | `SwiftUIRegistryCLI` used `@Dependency` without declaring the `Dependencies` product — relied on transitive resolution via RegistryKit | **done** |
| Core-vs-platform-optional split (shallow contract + opt-in UI product) | swift-sharing/swift-composable-architecture manifests | **applies — confirmed clean, better than the comparison libraries** | `SwiftUIRegistryFoundations` (0 deps) + `SwiftUIRegistryDesignSurface` (`#if canImport(UIKit)`, inert in release) already is this split | skip |
| Speculative sub-split of DesignSurface into core/UI targets | AGENTS.md "2 concrete consumers" rule | does_not_apply | No third consumer for a UIKit-free token model — RegistryKit already owns its own SwiftUI-free preset codec | skip |
| Macro target / TestSupport product patterns | swift-dependencies manifest | does_not_apply | No macros in this repo; the one test helper has a single consumer | skip |
| One test target per production target | swift-dependencies/TCA test-target split | partially_applies | `RegistryKitTests` tests both `RegistryKit` and `SwiftUIRegistryCLI` — defensible given the CLI's size (844 lines) | not done (churn > value) |

### 2. The Dependencies library (swift-dependencies)

| Idea | Source | Verdict | Current state | Priority |
|---|---|---|---|---|
| Tests must enter `.test` `DependencyContext` explicitly under Swift Testing (unlike XCTestCase, it's never auto-inferred) | `Dependencies.swiftinterface`, pfw-dependencies skill | **applies** | Test target linked no `DependenciesTestSupport`; no `.dependencies` trait — the throwing `testValue`s already written for network/archive/tags keys were dead code | **done** |
| Effectful `DependencyKey`s should have an explicit `testValue` so a forgotten override fails/throws instead of silently reaching `liveValue` | pfw-dependencies skill | partially_applies | 3 of 7 keys had one (network/archive/tags); `RegistryInputKey` (blocks on real stdin) and `SourceMergerKey` (spawns real `git`) did not | **done** (both, cleanly throwable) — `FileSystemKey`/`RegistryConsoleKey` left alone: FileSystem's protocol has non-throwing members a safe stub can't fully guard without a larger rewrite, and Console's liveValue is low-risk (just prints) |
| `@DependencyClient` macro to synthesize the 6 hand-rolled struct-of-closures clients | DependenciesMacros.swiftinterface | applies | All 6 clients are the exact shape the macro targets | not done — adds a macro dependency + refactors 6 types for modest gain on a working tool |
| Over-application check: `@Dependency` should wrap only real effects | pfw-dependencies skill + Rule 5 | **does_not_apply — confirmed clean** | Every site is a real effect (disk/network/process/stdio/uuid/clock); the seeded `PythonRandom` generator correctly has none | skip |
| App-entry `prepareDependencies` bootstrap | pfw-dependencies skill | does_not_apply | Nothing is constructed from a runtime secret; ambient `liveValue` in the live context is already correct | skip |

### 3. @Shared / the Sharing library

| Idea | Source | Verdict | Current state | Priority |
|---|---|---|---|---|
| Persisted state via `@Shared` with a typed `SharedKey` default, `.withLock` mutation, `.loadError` decode handling, tested via `withDependencies { $0.defaultFileStorage = ... }` | pfw-sharing skill | **applies — already realized to the canonical letter** | `.designTokens`/`.designKnobs` (`DesignTokens.swift`, `KnobStore.swift`) match the skill's exact pattern; tests already use Sharing's own test utilities | skip |
| `.appStorage` for state persisted/reset from outside a view, vs. view-bound `@AppStorage` | pfw-sharing skill | partially_applies | Panel geometry uses `@AppStorage` with keys centralized via `PanelGeometry.storageKey`; the button's two keys were duplicated string literals across two files — a latent bug if one changed | **done** (minimal fix: named the keys once; did not do the fuller `@Shared(.appStorage)` migration — `@AppStorage` is idiomatic for view-local geometry, only the duplication was the real defect) |

### 4. Observation & modern SwiftUI + `@LazyState`

| Idea | Source | Verdict | Current state | Priority |
|---|---|---|---|---|
| `@LazyState` for a `@State` model built from external init parameters | `pointfreeco/swiftui-lazy-state` README (fetched) | **does_not_apply** | Zero `State(wrappedValue:)` sites anywhere in the repo — the exact scenario the macro targets doesn't occur. Legitimate library, no consumer here | skip |
| Derive bindings via `@Bindable` + dynamic member lookup / subscript, never `Binding(get:set:)` | pfw-modern-swiftui skill ("NEVER use Binding.init(get:set:)") | **applies** | `FloatingTuneButton` hand-rolled two bindings with `Binding(get:set:)` — the cited anti-pattern | **done** |
| View-local navigation `@State` ownership/naming | pfw-modern-swiftui skill | does_not_apply (for this topic) | `TuningPanel`'s `path: [String]` is already idiomatic ownership/naming; the domain-modeling question (should it be typed) belongs to topic 5 | skip here |

### 5. Enum-driven navigation and domain modeling + CasePaths

| Idea | Source | Verdict | Current state | Priority |
|---|---|---|---|---|
| Replace stringly-typed `status: String` with enums for exhaustive, typo-proof switches | pfw-swift-navigation skill (enum-over-stringly-typed) | **applies** | `Installer.FileStatus.status` and `Inventory.File.status` were `public var status: String` across 3 disjoint vocabularies (plan/update/inventory) sharing types, with 2 magic-string filter sites and zero compiler protection | **done — flagged as a public API change first, approved by owner before implementing** |
| Enum `Destination` for `TuningPanel`'s `NavigationStack(path:)` | pfw-swift-navigation / pfw-case-paths skills | **does_not_apply** | Destinations are registered at *runtime* by the consuming host app (`hostPage: (String) -> View?`) — a package product can't enumerate a host's pages at compile time, so no closed enum is possible. `[String]` is the correct type across this plugin boundary | skip |
| `@CasePathable`/case key paths on the `JSON`/`OrderedJSON` enums | pfw-case-paths skill | partially_applies | The pattern fits the shape, but `grep 'if case' Sources/RegistryKit` returns only the 6 already-centralized accessor lines — zero scattered extraction to DRY up. Would add a dependency to the SwiftUI-free engine for marginal gain, and can't cleanly reproduce `OrderedJSON`'s nested-case accessor | not done — recommend against |

### 6. IssueReporting

| Idea | Source | Verdict | Current state | Priority |
|---|---|---|---|---|
| `reportIssue`/`withErrorReporting`: log-and-continue in production, hard-fail in debug/test | pfw-issue-reporting skill | **does_not_apply — confirmed clean** | This is a dev CLI tool with no shipping-app production runtime for the continue-in-production behavior to protect. The existing "typed errors + fail loud at the CLI boundary" pattern (`Validation.swift`, `Main.swift`) already covers this domain | skip |
| Convert the sole `try!` (a compile-time-constant MCP tools JSON literal) | pfw-issue-reporting skill | does_not_apply | No recovery value exists; `withErrorReporting` would return `nil` tools — strictly worse | skip |
| Soften internal-invariant force-unwraps (`items[name]!`) | pfw-issue-reporting skill | does_not_apply | All are controlled-input invariants in dev-CLI codepaths where a crash is the intended loud failure; user-authored data is already guarded upstream by `Validation.swift`'s typed issues | skip |

### 7. Testing: `@Suite`/`@Test` traits, dependency control

| Idea | Source | Verdict | Current state | Priority |
|---|---|---|---|---|
| A single base suite other suites extend, inheriting its traits | pfw-testing skill | partially_applies | `Commands` is already a de-facto base suite (~10 files extend it via `extension Commands`), but that scope was invisible from the bare declaration | **done** (doc comment added in the same edit as the `.dependencies` trait) |
| Exhaustive-by-default dependency overrides | pfw-dependencies skill | **applies — confirmed clean** | Every `DependencyKey` relies on the library's own default `testValue` (fails loudly on un-overridden access); no live dependency can silently leak | skip |
| Hoist repeated overrides onto the base suite via `.dependencies { }` | pfw-testing skill | partially_applies | Fixed-clock/git-merger overrides repeat across 3 harness helpers; centralizing is a legitimate but marginal ergonomics call — the current explicit form is arguably clearer for a test harness | not done — flagged as optional |
| Add `.timeLimit`/`.tags`/`.disabled`/`.bug` traits | swift-testing native traits | does_not_apply | No open defect to tag, suite is sub-second, whole-suite run in CI — would be scope creep | skip |

### 8. Snapshot testing of views (swift-snapshot-testing)

| Idea | Source | Verdict | Current state | Priority |
|---|---|---|---|---|
| `assertSnapshot(of: view, as: .image(...))` for automated per-item dark-mode/Dynamic-Type regression testing | pfw-snapshot-testing skill | partially_applies | Real gap: today, per-item dark/Dynamic-Type variants are reviewed manually (`docs/visual-testing.md` calls the captures "review evidence, not baselines"). But this would add a second image-golden corpus needing its own `GOLDEN-CHANGE` discipline, risk flakiness on Liquid Glass render content, and needs a new test-target dependency (`RegistryKitTests` is SwiftUI-free by contract; only `SwiftUIRegistryShowcaseFeatureTests` has an iOS host) | **recommended only, not applied** — risk was scored medium by the audit itself; expanding a deliberate, human-reviewed testing contract needs a named defect driving it, not a nice-to-have |

### 9. IdentifiedCollections + TCA integration boundary

| Idea | Source | Verdict | Current state | Priority |
|---|---|---|---|---|
| TCA/IdentifiedArray are application-logic libraries; they belong in consumer/app code, never in a source-owned UI library | pfw-composable-architecture skill + AGENTS.md Rules | **does_not_apply inside the registry — confirmed clean boundary** | `grep 'ComposableArchitecture' Sources/ Registry/sources/` → zero matches. TCA appears only in `Examples/TodoCounter`, the documented second consumer | skip |
| `IdentifiedArray` for `Registry.items`/`Inventory.items` | pfw-identified-collections skill | **does_not_apply** | `Registry.items` is already a `[String: JSON]` dictionary (O(1) by name); `Inventory.items` is a plain `[Item]` built once and only ever iterated, never looked up by id, and `Item` isn't even `Identifiable`. Converting either would add a dependency for zero measurable gain | skip |

## Phase 3: what changed (6 commits, one principle each)

| Commit | Principle | Touches | Risk |
|---|---|---|---|
| `54e142a` | Declare the `Dependencies` product for `SwiftUIRegistryCLI` explicitly | Package.swift | none |
| `b69bff2` | Run the command/CLI test suite in Dependencies' `.test` context (+ name `Commands` as the base suite) | Package.swift, 2 test files | low |
| `e95de52` | Give `RegistryInputKey`/`SourceMergerKey` throwing `testValue`s | RegistryKit | low |
| `2b0afe7` | Derive `FloatingTuneButton`'s bindings without `Binding(get:set:)` | DesignSurface | low |
| `931ed47` | Name the button's `AppStorage` keys once instead of duplicating literals | DesignSurface | none |
| `6c21bb3` | Replace stringly-typed file statuses with enums (wire-preserving) | RegistryKit, CLI, tests | low — **public API change, flagged and approved before implementing** |

None of these touch `Registry/sources/` (copy-owned component/block source), none add a dependency to
copy-owned source, and only the last one changes public API — which was surfaced and approved before
any code was written, per the standing instruction to stop and ask first.

## Deliberately not applied, and why

- **`@LazyState`** — legitimate library, zero consumers in this repo today (no `State(wrappedValue:)`
  parameterized-init pattern exists). Re-evaluate if a future view owns an `@Observable` feature model
  built from external parameters.
- **CasePaths on `JSON`/`OrderedJSON`** — would add a dependency to the SwiftUI-free engine to DRY up
  6 lines that are already centralized once, and can't cleanly reproduce `OrderedJSON`'s nested-case
  accessor. Recommend against.
- **IssueReporting** — this is a dev CLI with no production runtime; the existing typed-error +
  fail-loud-at-the-boundary pattern already covers its domain.
- **`IdentifiedArray`** — no keyed-lookup call site exists for either candidate collection; would add
  a dependency for no measurable gain.
- **Enum-driven `Destination` for `TuningPanel`** — the destination set is host-registered at runtime
  across a package/consumer boundary; no closed enum is possible here.
- **Per-item view-image snapshot testing** — real automation gap identified, but recommended only.
  Applying it would expand `docs/visual-testing.md`'s deliberate, human-reviewed golden-image contract
  and add real Liquid Glass flakiness risk; that trade deserves your explicit call, not an autonomous one.
- **`@DependencyClient` macro adoption, base-suite trait hoisting, splitting `RegistryKitTests`** — each
  reviewed and judged real-but-marginal: the churn (new macro dependency, or moving fixtures across ~10
  files, or renaming a test target) outweighs the ergonomics gain on a tool that already works.

## Phase 4: before / after

| Check | Before | After |
|---|---|---|
| `swift build` | clean, 0 warnings | clean, 0 warnings |
| `swiftui-registry validate` | passed: full catalog | passed: full catalog |
| `swift test` | **80/80** passed (8 Foundations, 72 RegistryKit), 0 failures | **80/80** passed, 0 failures (no tests added or removed — this pass hardened existing test *infrastructure*, not test count) |
| Generator drift (`git diff --exit-code -- docs/catalog Examples/Showcase Website/content .../RegistryItemTokens.swift`) | n/a | **no drift** — all 4 generators regenerated clean |
| Showcase simulator build (`SwiftUIRegistryDesignSurface` changes) | n/a | **succeeded**, 0 warnings, pinned iPhone 17 / iOS 27.0 simulator |
| Showcase full UI test suite | 2 known pre-existing failures per CHANGELOG (`auth-light`, `nutrition-light` stale references, unrelated to this work, pending owner's manual copy into `ReferenceImages/`) | run in background; see follow-up note |
