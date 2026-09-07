# SwiftUIRegistry agent guide

## Purpose

Validate a native-first, source-owned, registry-driven SwiftUI composition layer. Version 0 is intentionally small

The whole system is one loop: edit canonical source in `Registry/sources/` and metadata in `Registry/items/`, validate, regenerate `docs/catalog/`, reinstall into Showcase, compile, and verify visually. Everything downstream of metadata is derived, never hand-edited

## Document map

Each kind of fact lives in exactly one place. Four document classes:

- Contracts, which rules come from: this file, `docs/philosophy.md` (why), `docs/architecture.md` (how), `docs/registry-spec.md` (data and installer contract), `docs/visual-testing.md` (visual evidence rules), `docs/mango.md` (the design-system template)
- State, the only home of stage status, open deferrals, and plans: `docs/component-roadmap.md`. A status claim in any other file is a pointer, not a second source
- Generated, never hand-edited: `docs/catalog/` (markdown catalog), `Website/content/registry.json` and `Website/public/images/` (the website's data and captures; the site itself is Next.js with shadcn/ui under `Website/`), `Examples/Showcase/.../RegistryCatalogManifest.swift` and `Examples/Showcase/SwiftUIRegistryShowcaseUITests/RegistryItemNames.swift` (the Showcase manifest), and `docs/images/items/` and `docs/images/themes/` (captures). Current item counts and per-item pages live there, not in prose
- Archives, closed dated records kept as evidence, not updated: `STAGE_ONE_VALIDATION.md`, `GENERAL_DIRECTION_REVIEW.md`, `docs/clean-room-trial.md`, `docs/research.md`, `tasks/`. `HANDOFF.md` is the brief for the next session and points here for state

On conflict: state beats archives, the more recent dated record wins between archives, and contracts govern rules regardless. Surface the conflict, then fix the stale text rather than averaging

`docs/registry-spec.md` "Agent usage" addresses an agent consuming the registry from another app. This file addresses an agent developing the registry

## Boundaries

- `Sources/SwiftUIRegistryFoundations/` is the stable package interface for design foundations only
- `Sources/RegistryKit/` is the SwiftUI-free engine behind the `swiftui-registry` executable in `Sources/SwiftUIRegistryCLI/`: loading, the single structural validator, resolution, receipts, installation and merge, search, preset codes, the MCP server, and the three generators. It never imports `SwiftUIRegistryFoundations`; `Tests/RegistryKitTests/` holds its contracts and captured fixtures
- `Registry/sources/components/` contains source-owned styles, focused modifiers, and reusable compositions
- `Registry/sources/blocks/` contains source-owned compositions of components
- `Registry/items/` is machine-readable metadata and the dependency graph; `Registry/preset_vectors.json` pins the preset codes every codec reproduces
- `Distribution/homebrew/` is the formula template for the owner's Homebrew tap, and `.github/workflows/release.yml` builds the universal binary when a GitHub release is published; neither is exercised by the verification list
- `Examples/TodoCounter/` is a second consumer built from a fresh Xcode project: the published package by URL, the Composable Architecture, seven items installed with the released tool, a customized preset theme, and one locally edited component. It is not part of the verification list; its own test plan runs from its workspace
- `Examples/Showcase/` proves installation, integration, and visual contracts. It is a browsable catalog (Components, Blocks, Recipes) with the tuning panel beside it, whose item list and usage snippets come from the generated manifest; every item has a demo registered in `ItemDemos.swift`, and the `-item <name>` launch renders that demo alone for capture

## Rules

- Keep raw SwiftUI controls and containers visible at the call site. Standardize interactive appearance with SwiftUI style protocols and optional behavior with focused `ViewModifier`s. Do not add a wrapper only to rename an Apple control
- Configure reusable views with prepared values, bindings, actions, and sensible defaults. Use `@ViewBuilder` when a container provides structure or chrome around arbitrary caller content
- Prefer modifiers over adding parameters for independent optional decorations or behavior
- A registry view's initializer carries what it is (content, bindings, actions, required accessibility input); a presentation choice the view owns (variant, tone, tint, a future size or emphasis) is a `registry`-prefixed copy-and-return method on the view applied before generic modifiers, as in `InlineAlert(...) { }.registryVariant(.positive)`. Native controls keep presentation in a `registry` style, text treatments in a `registry` modifier with a variant argument, the theme in the environment, and sizes through Apple's `controlSize`; a `ViewModifier` is for optional decorations that do not reach a component's internal layout
- Keep controlled state with the caller through bindings. A component may own transient `@State` only when the interaction is genuinely self-contained and no caller must coordinate it
- Registry source does not import app architecture, networking, or persistence libraries
- Keep copied items understandable in isolation and list every source dependency in registry metadata
- Use semantic foundation tokens instead of repeated hardcoded colors or metrics. Add a token only when at least two real registry items need the same semantic value
- Keep a style or modifier source-owned until at least two registry items use the exact same treatment; only then consider moving the shared treatment into foundations
- Respect environment values and layout proposals. Support Dynamic Type, color scheme, layout direction, enabled state, and flexible parent sizing rather than hardcoding one context
- Require accessibility input when it cannot be derived from visible content. Do not make labels for icon-only controls optional
- Preview every meaningful variant, including dark appearance and an accessibility Dynamic Type size
- Do not create an extra reusable abstraction without two concrete consumers or named roadmap usages
- Every installable item (component or block) needs a version, preview, accessibility notes, supported platform metadata, and a compile path. A `recipe` item is non-installing native guidance: empty `files`, non-empty `docs`, no preview requirement, and no installable item may depend on it (see the value gate in `docs/registry-spec.md`)
- Every item of any kind needs a non-empty `usage` snippet: a minimal call-site example quoted from the item's real public API as declared in its canonical source, never written from memory. Recipes reuse the native snippet from their `docs`
- `docs/catalog/` is generated by `swift run swiftui-registry generate catalog`, the website's data by `swift run swiftui-registry generate site-data`, and the Showcase manifest by `swift run swiftui-registry generate showcase-manifest`; never edit any of them by hand. Regenerate all three after any metadata or registry source change; `generatedOutputsMatchCanonicalBytes` in `Tests/RegistryKitTests/GeneratorTests.swift` rejects drift byte for byte. The site's pages under `Website/app` are hand-written React and read only that JSON; `npm run build` in `Website/` exports it statically
- Item screenshots come from `python3 Scripts/capture_previews.py` on the pinned simulator, never from hand-made images; recapture an item after a visible change to it and regenerate the catalog and site
- Never regenerate visual references merely to pass a test; follow `docs/visual-testing.md`
- Add dependencies only when a vertical slice proves they are necessary
- `Sources/RegistryKit/Validation.swift` is the only place registry structure is enforced; add or change structural checks there, never as ad hoc checks in commands or tests (see Validation in `docs/registry-spec.md`)

## Environment pins

- Visual contract and UI tests run on the light-mode iPhone 17, iOS 27.0 simulator; on this machine its UDID is `1807166B-C557-4F6B-B177-D5F3F701CBD7` (`docs/visual-testing.md`)
- Captures launch the app with `-AppleLanguages (en) -AppleLocale en_US`, so dates, currency, and the calendar in an image never depend on a simulator's region; the iPad Pro 13-inch used for the wide block captures is set to en_US as well because the status bar date comes from the device (it was ar_SA until 2026-09-06)
- Toolchain: Xcode 27.0, Swift 6.4. No iOS 26 simulator runtime is installed, so floor-26 claims rest on compilation plus iOS 27 runtime evidence
- CI builds the tool on GitHub's `macos-26` image with its default Xcode 26.6 (`.github/workflows/ci.yml`); the package declares Swift tools 6.2. That runner has not executed a push yet, so the first green run is the owner's evidence
- Package identity for consumers: `swiftui-ui-registry` at github.com/mangobyte-dev/swiftui-ui-registry. No tag is published yet; the first must be `0.1.0` so declared floors resolve (`docs/registry-spec.md`)

## Verification

Run from the repository root, cheapest first, so a defect fails the run before expensive steps:

```sh
swift build
swift run swiftui-registry validate
swift run swiftui-registry generate catalog
swift run swiftui-registry generate showcase-manifest
swift run swiftui-registry generate site-data
git diff --exit-code -- docs/catalog Examples/Showcase Website/content
swift test
make format-check
swift run swiftui-registry search nutrition dashboard --kind block --platform iOS --target-version 26.0
swift run swiftui-registry install finance-overview --destination Examples/Showcase/SwiftUIRegistryShowcasePackage/Sources/SwiftUIRegistryShowcaseFeature/Installed --force
swift run swiftui-registry install nutrition-overview --destination Examples/Showcase/SwiftUIRegistryShowcasePackage/Sources/SwiftUIRegistryShowcaseFeature/Installed
xcodebuildmcp simulator build --workspace-path Examples/Showcase/SwiftUIRegistryShowcase.xcworkspace --scheme SwiftUIRegistryShowcase --simulator-name 'iPhone 17'
xcodebuildmcp simulator test --workspace-path Examples/Showcase/SwiftUIRegistryShowcase.xcworkspace --scheme SwiftUIRegistryShowcase --simulator-id 1807166B-C557-4F6B-B177-D5F3F701CBD7
(cd Website && npm ci && npm run typecheck && npm run build)
```

Scope the run to the change: a metadata-only change stops after `make format-check`, a registry source change needs the install and compile steps, and only a visible UI change needs the simulator test. `swift test` needs `git` and Node 22 on PATH: the merge adapter shells out to `git merge-file`, and the website codec check runs `Website/lib/preset.ts` under `node --experimental-strip-types`. A visible change to an item also needs `python3 Scripts/capture_previews.py <item>` (the one remaining Python script, which lists items through the built tool) followed by the three generators. A change under `Website/` needs the typecheck and build. A change is incomplete if generated consumer sources differ from registry sources or any executed command fails; a skipped step is named in the done-claim
