# SwiftUI Registry direction review

Review date: 2026-08-30

## Executive verdict

**Continue with corrections.** Confidence: **high (0.86)**.

The central architecture is the right one: keep Apple controls visible, distribute product-level SwiftUI as editable source, retain only a narrow shared foundation, and make discovery and dependency resolution machine-readable. The strongest repository evidence is not the nominal 21-item Stage 1 catalog. It is the complete path from metadata to dependency resolution to source installation to a compiling consumer, plus two recognizably native blocks whose callers retain formatting, state, navigation, and actions (`docs/architecture.md`, `Scripts/install.py`, `Scripts/search.py`, `Registry/sources/blocks/FinanceOverview.swift`, `Registry/sources/blocks/NutritionOverview.swift`, and `Examples/Showcase/SwiftUIRegistryShowcasePackage/Sources/SwiftUIRegistryShowcaseFeature/ContentView.swift`). The current tree also has unusually thoughtful update semantics for an early prototype: exact-content receipts, base snapshots, clean three-way merging, conflict artifacts, and closure-wide preflight (`Scripts/install.py`; `docs/registry-spec.md`).

The direction is not yet the strongest shadcn-like product for SwiftUI because Stage 1 confuses catalog parity with user value, the clean-room adoption path is incomplete, and discovery/documentation is much weaker than the underlying registry machinery. Several installed “components” add no treatment beyond renaming a native SwiftUI style, which conflicts with the repository's own rule against wrappers that merely rename Apple controls (`AGENTS.md`; `Registry/sources/components/RegistryNativeSelectModifier.swift`; `Registry/sources/components/RegistryRadioGroupModifier.swift`; `Registry/sources/components/RegistryTabsModifier.swift`; `Registry/sources/components/RegistrySwitchToggleStyle.swift`). Two more items install private preview-only examples rather than reusable APIs (`Registry/sources/components/RegistryAspectRatioExamples.swift`; `Registry/sources/components/RegistryDirectionExamples.swift`). Those items make the catalog look broader while making source ownership noisier.

The smallest correction is therefore not a new architecture. It is a product-focus correction: preserve the hybrid model and installer, stop treating the shadcn component list as a build queue, classify native guidance separately from installable components, and make one external clean-room install/customize/update workflow excellent before adding Stage 2 breadth.

## Evidence scope and uncertainty

This review uses the current working tree, including uncommitted Stage 1 corrections. Repository evidence includes all governing documents, all 26 registry item documents and canonical Swift sources, the foundation package, installer/search scripts, Python and Swift tests, Showcase source, UI tests, and checked-in screenshots. A local read-only audit reported:

```text
items=26 components=24 blocks=2 flows=0
foundation_dependent=18 foundation_free=8
items_with_registry_dependencies=5
items_with_screenshots=2
canonical_install_pairs=26 equal=26 unequal=0
```

The current Python registry suite independently passed:

```text
..............................
----------------------------------------------------------------------
Ran 30 tests in 0.278s

OK
```

The documented search command returned `nutrition-overview`, and `git diff --check` produced no diagnostics. These commands were run from the repository root on 2026-08-30. The successful Xcode package, build, and pinned-runtime UI runs are documentary evidence from `STAGE_ONE_VALIDATION.md`; they were not rerun for this non-implementation review.

There is conflicting completion evidence. `README.md` and `docs/component-roadmap.md` call Stage 1 complete, while `STAGE_ONE_VALIDATION.md` marks Phase 8 “in progress.” The ledger records substantial runtime and compile evidence, but the work is uncommitted and its own final autonomous pass is not recorded as complete (`STAGE_ONE_VALIDATION.md`; current `git diff --stat` reports 41 changed files, 555 insertions, and 146 deletions). The correct conclusion is “strong prototype evidence,” not “finished release evidence.”

There is no supplied user research or production-app adoption data; `PRODUCT.md` says this explicitly. The meaningful-problem and adoption conclusions below are therefore hypotheses supported by repository quality and market mechanics, not proof of demand.

Current shadcn evidence comes from first-party sources. shadcn now describes itself as both accessible components and a code-distribution platform, organized around open code, composition, distribution, good defaults, and AI-readiness ([Introduction](https://ui.shadcn.com/docs)). Its CLI supports initialization, add, dry-run, diff, view, search across registries, registry build, docs lookup, migrations, presets, and ejecting its shared Tailwind dependency ([CLI](https://ui.shadcn.com/docs/cli)). Its item schema supports multiple item types, package and registry dependencies, explicit targets, docs, categories, themes, styles, and arbitrary metadata ([registry-item.json](https://ui.shadcn.com/docs/registry/registry-item-json)). Its MCP workflow browses, searches, and installs from public, private, third-party, and namespaced registries ([MCP](https://ui.shadcn.com/docs/mcp)). Blocks are previewable multi-file application compositions installable by name ([Blocks](https://ui.shadcn.com/blocks)). These are web capabilities, not requirements to copy literally.

## What the project gets right

1. **The native seam is correct.** `ButtonStyle`, `ToggleStyle`, `TextFieldStyle`, `ProgressViewStyle`, `GroupBoxStyle`, and focused modifiers preserve SwiftUI's bindings, roles, environment propagation, and platform evolution. The Showcase keeps raw `Button`, `Toggle`, `TextField`, `TextEditor`, `Picker`, `Slider`, `ProgressView`, `Divider`, `ControlGroup`, and `GroupBox` visible at use sites (`Examples/Showcase/SwiftUIRegistryShowcasePackage/Sources/SwiftUIRegistryShowcaseFeature/StageOneShowcase.swift`). This is the appropriate native adaptation of shadcn's open-code principle, because Apple already supplies the behavioral primitive layer that Radix/Base UI must supply on the web.

2. **The package/source split is coherent.** `SwiftUIRegistryFoundations` contains one environment value, semantic values, metrics, and one surface modifier; product components and blocks remain copied source (`Package.swift`; `Sources/SwiftUIRegistryFoundations/RegistryTheme.swift`; `docs/architecture.md`). A narrow shared substrate plus open top-layer code is compatible with shadcn's current model, which itself has shared theme infrastructure and an explicit eject path rather than treating every byte as copied source ([Theming](https://ui.shadcn.com/docs/theming), [CLI eject](https://ui.shadcn.com/docs/cli#eject)).

3. **The block APIs are recognizably SwiftUI.** `FinanceOverview` and `NutritionOverview` accept `LocalizedStringResource`, prepared `Text`, typed IDs, arrays, colors, and actions. They do not import stores, networking, persistence, routers, or an application model (`Registry/sources/blocks/FinanceOverview.swift`; `Registry/sources/blocks/NutritionOverview.swift`). `FinanceOverview` deliberately omits scrolling and width policy, which the Showcase supplies at the call site (`docs/architecture.md`; `Examples/Showcase/SwiftUIRegistryShowcasePackage/Sources/SwiftUIRegistryShowcaseFeature/ContentView.swift`).

4. **The registry is inspectable and deterministic.** JSON item documents declare versions, source/target paths, registry dependencies, package requirements, platform floors, tags, accessibility notes, and previews (`Registry/schema.json`; `Registry/items/`). Dependency resolution is depth-first and ordered, rejects cycles and unknown items, and preflights unsafe paths and duplicate targets (`Scripts/install.py`; `docs/registry-spec.md`). The local audit found all 26 canonical/installed file pairs byte-identical.

5. **The update design is stronger than simple copy-paste.** Receipts distinguish source, base, and installed digests. Local-only edits survive; disjoint upstream/local edits merge; overlapping edits leave owned source untouched and create a review artifact (`Scripts/install.py`; `Tests/RegistryTests/test_installer.py`). shadcn's public `add` UX exposes overwrite, dry-run, diff, and view, but its first-party CLI page does not document an equivalent receipt-backed three-way merge ([CLI add](https://ui.shadcn.com/docs/cli#add)).

6. **Accessibility and adaptation are treated as contracts.** Metadata carries accessibility notes; Stage 1 source includes dark, RTL, and accessibility-size previews; UI tests assert native semantics, write-through binding behavior, reachability under large text, minimum hit sizes, and RTL mirroring (`Registry/items/`; `Tests/RegistryTests/test_installer.py`; `Examples/Showcase/SwiftUIRegistryShowcaseUITests/SwiftUIRegistryShowcaseUITests.swift`). The screenshots show native iPhone/iPad composition rather than a web visual transplant (`docs/images/`).

## Critical weaknesses and risks

### 1. High: nominal component parity is diluting the native-first promise

`registryNativeSelect()` only applies `.pickerStyle(.menu)`, `registryRadioGroup()` only applies `.pickerStyle(.inline)`, `registryTabs()` only applies `.pickerStyle(.segmented)`, and `RegistrySwitchToggleStyle` only reconstructs the native toggle with `.switch` (`Registry/sources/components/RegistryNativeSelectModifier.swift`; `Registry/sources/components/RegistryRadioGroupModifier.swift`; `Registry/sources/components/RegistryTabsModifier.swift`; `Registry/sources/components/RegistrySwitchToggleStyle.swift`). `registrySlider()` is principally a forwarding convenience for `.tint` and `.controlSize` (`Registry/sources/components/RegistrySliderModifier.swift`). `aspect-ratio` and `direction` install source files whose only view types are private previews (`Registry/items/aspect-ratio.json`; `Registry/items/direction.json`; their referenced sources).

This conflicts with “do not add a wrapper only to rename an Apple control” and “one item must be useful” (`AGENTS.md`; `docs/philosophy.md`). It also imposes more names for developers and agents to learn without creating a stronger composition contract. Keep the examples, but classify them as recipes/guidance or documentation; do not count them as installable component capability.

### 2. High: the adoption path stops before Xcode integration

Eighteen of 26 items declare `SwiftUIRegistryFoundations` with the non-actionable metadata requirement `0.x`; the schema stores package name/product/requirement but no source URL or machine-resolvable SwiftPM rule (`Registry/items/`; `Registry/schema.json`). `README.md` tells the consumer to add the package first. The installer requires an explicit destination, reports but does not install package dependencies, and does not manage target membership or project files (`README.md`; `Scripts/install.py`; `docs/architecture.md`). This boundary is defensible for safety, but the product currently offers no first-class preflight that tells a user whether the chosen target can compile the installed closure.

shadcn's CLI makes project configuration part of the product: it initializes configuration/dependencies, resolves target locations, supports monorepos, previews writes, shows diffs and files, and installs declared dependencies ([CLI](https://ui.shadcn.com/docs/cli), [components.json](https://ui.shadcn.com/docs/components-json), [registry item targets](https://ui.shadcn.com/docs/registry/registry-item-json#files)). SwiftUI Registry should not mutate `.xcodeproj` blindly, but it does need a guided, verifiable installation contract rather than leaving the hardest integration step to prose.

### 3. High: roadmap order validates inventory before product value

The roadmap schedules forms, content, presentation/navigation adapters, complex components, and messaging before a blocks phase, while the repository's best evidence already comes from two blocks and three block-driven components (`docs/component-roadmap.md`; `Registry/sources/blocks/`; `Registry/sources/components/MetricCard.swift`; `Registry/sources/components/TransactionRow.swift`; `Registry/sources/components/MacroProgress.swift`). This is backwards for the stated thesis. A shadcn list is useful research input, not a SwiftUI implementation queue. The next slices should begin with valuable native product workflows, then extract only the exact reusable seams they prove.

### 4. Medium-high: discovery is machine-readable but not yet product-grade

`Scripts/search.py` requires every tokenized query term to occur in name, tags, description, or kind and ranks only exact token presence. It has no categories, aliases, related items, usage snippets, rendered preview lookup, or cross-registry source (`Scripts/search.py`). Only the two block items declare screenshots; the other 24 rely on preview names and source paths (local audit; `Registry/items/`). There is no per-item documentation surface comparable to shadcn's preview/code/API flow, CLI `view`/`docs`, registry directory, or MCP search/install experience ([Blocks](https://ui.shadcn.com/blocks), [CLI](https://ui.shadcn.com/docs/cli), [MCP](https://ui.shadcn.com/docs/mcp)).

The product can remain local and static at this size, but developers need to see a result, inspect its API and required dependencies, and understand its native rationale before copying it.

### 5. Medium: metadata validation is split between runtime and tests

`Registry/schema.json` is the canonical schema, but `Installer._validate_item` checks only required keys, schema version, and kind; it does not execute the JSON Schema or fully validate field types and formats (`Scripts/install.py`; `Registry/schema.json`). Repository tests add substantial structural and semantic checks, but a consumer running the installer does not receive the same assurance (`Tests/RegistryTests/test_installer.py`). The registry should have one validation command/library used by CI, search, install, and future hosting.

### 6. Medium: foundation stability is asserted before its compatibility policy exists

The foundation grew during the current audit from four layout metrics to semantic opacity and additional control metrics (`git diff -- Sources/SwiftUIRegistryFoundations/RegistryTheme.swift`; `STAGE_ONE_VALIDATION.md`). That extraction is evidence-based and the tokens have tested consumers, but it shows that the “stable package interface” is still discovering its boundary. Receipts record copied item versions and digests, not the actually resolved foundation version (`Scripts/install.py`; installed `.swiftui-registry/receipt.json`). Before external release, document compatibility, give package requirements machine-actionable semantics, and verify copied source against both its deployment floor and supported foundation range.

### 7. Medium: evidence is broad but still self-referential

The Showcase consumes exact installed bytes and exercises useful variants, but it is maintained in the same repository by the same rules (`Examples/Showcase/`). `PRODUCT.md` explicitly records no user research or production-app data. The project has proved internal coherence, not yet reduced integration time or improved results for an independent SwiftUI team or coding agent.

## Capability matrix

| Capability | shadcn/ui today | Current SwiftUI Registry | Appropriate native SwiftUI equivalent |
|---|---|---|---|
| Source ownership | Top-layer component code is installed into the app and edited locally ([Introduction](https://ui.shadcn.com/docs)) | Canonical component/block source is copied and receipt-backed (`Scripts/install.py`) | Keep product compositions source-owned; package only stable cross-item contracts |
| Primitive layer | Uses Base UI, Radix, or React Aria to supply web interaction/accessibility primitives ([CLI init](https://ui.shadcn.com/docs/cli#init)) | Keeps Apple controls visible and styles them with native protocols (`AGENTS.md`; `StageOneShowcase.swift`) | Let SwiftUI own controls, navigation, presentation, focus, and OS adaptation |
| Composition | Shared component conventions and multi-file blocks ([Introduction](https://ui.shadcn.com/docs), [Blocks](https://ui.shadcn.com/blocks)) | Typed prepared-value blocks with explicit component dependencies (`FinanceOverview.swift`; `NutritionOverview.swift`) | Prefer domain/use-case blocks and `@ViewBuilder` structural containers over control wrappers |
| Theme/defaults | Semantic CSS tokens, styles, presets, dark mode, and configurable bases ([Theming](https://ui.shadcn.com/docs/theming); [CLI](https://ui.shadcn.com/docs/cli)) | Four semantic colors, opacity, metrics, app tint, and editable source (`RegistryTheme.swift`) | Use environment-driven semantic roles sparingly; inherit system typography/materials/tint |
| Registry graph | Rich item types, package/dev/registry dependencies, targets, docs, categories, styles/themes ([registry-item.json](https://ui.shadcn.com/docs/registry/registry-item-json)) | Component/block/flow, paths, registry/package dependencies, platform, accessibility, preview (`Registry/schema.json`) | Add only native-useful types such as recipe/guidance and actionable SwiftPM/platform constraints |
| Install UX | Init/add with dependency setup, path config, dry-run, diff, view, overwrite ([CLI](https://ui.shadcn.com/docs/cli)) | Explicit destination; exact copy; force; manual package/target integration (`README.md`; `Scripts/install.py`) | Provide plan/view/diff/preflight and generated integration instructions; avoid unsafe project mutation |
| Updates | Re-add/overwrite, migrations, presets, and eject are documented ([CLI](https://ui.shadcn.com/docs/cli)) | Receipt-backed skip, preserve, update, merge, or conflict artifact (`Scripts/install.py`) | Retain three-way ownership; add human-readable plan/diff and foundation compatibility checks |
| Discovery/docs | Website, previews, code, CLI search/view/docs, directory, MCP ([Blocks](https://ui.shadcn.com/blocks); [MCP](https://ui.shadcn.com/docs/mcp)) | Deterministic local JSON search and source previews (`Scripts/search.py`; `Registry/items/`) | Start with generated static catalog/API examples; add MCP/hosting only when catalog use proves it |
| Multiple/private registries | Namespaced, GitHub, authenticated, public/private registries ([registry-item.json](https://ui.shadcn.com/docs/registry/registry-item-json); [MCP](https://ui.shadcn.com/docs/mcp)) | One local registry (`Registry/registry.json`) | Defer federation/authentication; keep the schema transport-neutral |
| Quality evidence | Accessible defaults and public examples; registry tooling supports validation ([Introduction](https://ui.shadcn.com/docs)) | Compile path, metadata tests, adaptive UI tests, visual references, canonical/install parity (`Tests/`; `Examples/Showcase/`; `docs/visual-testing.md`) | Make deployment-floor compile, accessibility contract, and adaptive previews publication gates |
| AI workflow | Open code, MCP, machine registry, docs lookup ([Introduction](https://ui.shadcn.com/docs); [MCP](https://ui.shadcn.com/docs/mcp)) | Agent-legible JSON/search, understandable Swift, no MCP (`PRODUCT.md`; `Scripts/search.py`) | Prove deterministic local agent workflow first; expose the same validated core through MCP later |

## Direct answers to the ten evaluation questions

1. **Keeping Apple primitives visible is the right equivalent.** Yes. Source ownership should expose the code that adds product structure or a meaningful style, not obscure `Button`, `Toggle`, `Picker`, `NavigationStack`, or system presentation. The current call sites prove this (`StageOneShowcase.swift`). The correction is to remove aliases that merely rename native style choices.

2. **The hybrid model is sound.** Yes, conditionally. Shared foundations solve cross-file theme identity and safe coordinated updates; copied product UI preserves local ownership (`docs/architecture.md`). It becomes lock-in if most useful items require a fast-growing package or if package compatibility remains informal. Keep the package narrow, make foundation-free items valid, and publish a compatibility policy.

3. **Stage 1 establishes useful seams, but not every item earns component status.** Button/input/textarea/card/badge/checkbox styles, theme environment, caller-owned bindings, prepared values, and blocks are useful seams (`Registry/sources/`). Native-select, radio-group, tabs, switch, slider, aspect-ratio, and direction need reclassification or stronger proven treatment.

4. **The product machinery is coherent but incomplete at the adoption edge.** Metadata, resolution, receipts, conflict-aware updates, search, Showcase installation, parity tests, and UI evidence align (`Registry/`; `Scripts/`; `Tests/`; `Examples/Showcase/`). Package/target integration, plan/diff/view, unified validation, and per-item documentation are missing.

5. **The theme is deep enough for the current proof, not yet a universal design foundation.** Its narrow semantic roles and native tint respect SwiftUI (`RegistryTheme.swift`). Do not add a shadcn-sized token matrix preemptively. Validate Stage 2 needs and establish compatibility before calling the package stable.

6. **The strongest APIs are composable, editable, accessible, adaptive, and native.** The blocks and substantive styles satisfy that description. The alias items are editable but add no useful composition. Accessibility evidence is good for a prototype, while physical-device assistive-technology coverage remains explicitly absent (`PRODUCT.md`).

7. **The roadmap is not ordered correctly.** It should prioritize complete product workflows and adoption UX, then extract repeated components. Presentation/navigation adapters should mostly become recipes unless a real block proves reusable source. Do not wait through five component stages to build more blocks (`docs/component-roadmap.md`).

8. **Important missing shadcn-like capabilities are inspect-before-write, integration preflight, item documentation, visual browsing, actionable dependency setup, unified registry validation, and eventually an agent adapter.** Current shadcn exposes these through CLI view/dry-run/diff/docs/search and MCP ([CLI](https://ui.shadcn.com/docs/cli); [MCP](https://ui.shadcn.com/docs/mcp)). Remote registries, authentication, and marketplaces are not pre-Stage-2 requirements.

9. **The main future risks are package coupling, alias API clutter, inventory-led roadmap growth, manual Xcode integration, weak discovery, and premature stability claims.** The update receipt itself reduces lock-in and should be retained (`Scripts/install.py`).

10. **The project addresses a meaningful problem strongly enough to continue, but demand is unproved.** The repository demonstrates a credible answer to “how can a team or agent discover, own, adapt, and safely evolve native product UI without adopting an app architecture?” (`PRODUCT.md`; `README.md`). It has not shown that independent teams prefer this over snippets, internal packages, or bespoke composition.

## Smallest corrections before Stage 2

1. **Define an item-value gate and taxonomy.** An installable component must add a meaningful reusable treatment or composition. Move preview-only native guidance and one-line aliases to a non-installing recipe/guidance category, or remove them from the catalog. Preserve their documentation value.
2. **Make install inspectable and verifiable.** Add a plan/dry-run mode that prints the dependency closure, target writes, package requirements, collisions, and integration steps; add view/diff for owned versus incoming source. Do not mutate Xcode projects automatically.
3. **Make package requirements actionable.** Replace `0.x` prose with a defined SwiftPM source and requirement representation, document compatibility, and record the expected foundation constraint in provenance.
4. **Unify registry validation.** Use one validator in tests, search, install, and any generated catalog. Validate the canonical schema plus source existence, dependency closure, platform constraints, preview evidence, and package requirements.
5. **Generate a static item catalog from metadata.** Each high-value item needs purpose, native seam, install command, dependency closure, public API example, accessibility contract, preview/source links, and supported platforms. This can remain local/static; MCP and hosting are not required.
6. **Run one clean-room adoption study.** In an app outside `Examples/Showcase`, have an independent developer or coding agent discover, inspect, install, compile, customize, and update one block. Record time, manual steps, failure points, and whether the owned source was understandable. This is the missing go-to-product evidence.

These corrections do not require changing the core package/source split, replacing the installer, adding third-party dependencies, or broadening the platform floor.

## Roadmap changes

Replace catalog-parity stages with vertical product slices:

- **Stage 1.5: adoption contract.** Item taxonomy/value gate, unified validation, inspectable install, actionable package requirements, generated item docs, and one clean-room trial.
- **Stage 2: two block-led workflows.** Build an authentication form and a settings section, because they exercise validation, focus, secure input, autofill, switches, selection, and error feedback. Extract `field`, `input-group`, or form treatments only when the two slices prove the same seam. The current candidates and native mappings already exist in `docs/component-roadmap.md`.
- **Stage 3: content/feedback driven by one real screen.** Add empty/loading/inline-alert/row treatments only as required by a coherent workflow.
- **Later:** complex data, presentation guidance, and messaging based on named adopters. Treat native sheets, alerts, menus, navigation, scroll views, and split views as recipes by default, not installable wrappers.

Keep finance and nutrition as proof fixtures, but do not count illustrative domains as adoption evidence (`PRODUCT.md`).

## Prioritized next steps

### Must do before Stage 2

1. Reclassify or remove no-op and preview-only “components.”
2. Define and test the item publication gate.
3. Add install plan/view/diff and package/target preflight guidance.
4. Replace ambiguous `0.x` package metadata with an actionable compatibility contract.
5. Unify runtime and CI metadata validation.
6. Generate usable per-item documentation and complete one independent clean-room trial.
7. Reconcile the “Stage 1 complete” claim with the still-in-progress validation ledger before release (`README.md`; `docs/component-roadmap.md`; `STAGE_ONE_VALIDATION.md`).

### Should do during Stage 2

1. Deliver authentication and settings as complete dependency-closed blocks before expanding the primitive catalog.
2. Verify keyboard/focus/autofill/validation announcement behavior at the UI, as the existing Stage 2 exit criteria require (`docs/component-roadmap.md`).
3. Add search aliases/categories/related items based on observed queries, not speculative ontology.
4. Test updates where both a copied item and the foundation version change.
5. Capture item-level screenshots only where visual selection materially helps; do not turn every native alias into a golden-image burden (`docs/visual-testing.md`).

### Defer until real adoption proves the need

1. Hosted registry distribution, namespaces, authentication, private catalogs, federation, and dynamic server-side search.
2. MCP, Figma, marketplace, premium catalog, and multi-author workflows.
3. Automatic `.xcodeproj` mutation.
4. macOS, watchOS, tvOS, and visionOS claims.
5. A large typography/color/elevation token framework.
6. Broad presentation/navigation wrappers, complex data components, and messaging infrastructure without named block consumers.

## Explicit non-goals

- Do not rebuild Apple controls to imitate Radix, Base UI, or DOM accessibility behavior.
- Do not reproduce Tailwind class APIs, CSS-variable breadth, responsive breakpoints, web hover semantics, or literal shadcn variant matrices.
- Do not hide `Button`, `Toggle`, `Picker`, `TextField`, navigation, sheets, alerts, menus, or scrolling behind renamed wrappers.
- Do not install an app architecture, state container, networking layer, persistence framework, router, or dependency-injection system.
- Do not infer target membership or rewrite Xcode projects without an explicit, reviewable project-integration design.
- Do not optimize for component-count parity, a hosted marketplace, or cross-platform claims before independent iOS adoption.
- Do not promise painless upstream updates; preserve local ownership and make conflicts inspectable.
- Do not turn the narrow foundation into a mandatory universal design system.

## Final recommendation

**Go**, continuing in the current native-first, hybrid, registry-driven direction **after the pre-Stage-2 corrections above**. Do not pivot to a monolithic Swift package, a web-style control replacement library, or a larger token framework. Do pivot the roadmap and success metric: the product wins when an independent SwiftUI developer or coding agent can find a useful native composition, understand it, install it safely, compile it, customize it locally, and later inspect an update—not when the repository can map every shadcn component name to a Swift file.
