# Architecture

## Decision

Version 0 uses a hybrid distribution model:

```text
consumer app
├── depends on SwiftUIRegistryFoundations
└── owns copied component and block source
```

The package boundary is intentionally shallow. `SwiftUIRegistryFoundations` contains only the stable environment contract, one shared surface modifier, and the design surface's item hook (`registryItem(_:)`, an environment value, and an anchor preference, all inert without a surface). Registry components and blocks are not package products. `SwiftUIRegistryDesignSurface` is a second, optional product for debug builds: the tuning panel and its preset codec moved there from the Showcase on 2026-09-08 behind a `designSurface()` modifier and a swift-sharing file store, so any consumer app can tune the tokens on device and export them as `design-tokens.json` and a preset code. Foundations does not depend on it, it never imports registry items, and a consumer that only wants items never adds it

## Why this split

Foundations need one coherent update path across copied items. Product UI needs local modification, domain naming, and close integration with an app. Copying both would duplicate the foundation contract; packaging both would turn local product composition into a framework API compatibility problem

This is a hypothesis exercised by finance and nutrition, not a claim of universal reuse. A future item with no foundation dependency should be allowed

## Source tree

- `Sources/SwiftUIRegistryFoundations/`: stable package API
- `Registry/items/`: machine-readable item declarations
- `Registry/sources/components/`: canonical copied styles, focused modifiers, and reusable compositions
- `Registry/sources/blocks/`: canonical copied block source
- `Sources/RegistryKit/` and `Sources/SwiftUIRegistryCLI/`: the `swiftui-registry` tool, a SwiftUI-free engine (validation, dependency resolution, receipts, installation and conflict-aware updates, search, preset codes, the MCP server, the generators) behind an ArgumentParser executable
- `Examples/Showcase/`: a real iOS consumer, a browsable catalog with a demo per item, the theme tuning panel, and the capture route for item screenshots
- `Examples/TodoCounter/`: a consumer with a different architecture (the Composable Architecture), the package by URL at the published tag, items installed with the Homebrew tool, and a customized preset theme
- `swiftui-registry generate catalog | showcase-manifest | site-data`: the derived catalog, Showcase manifest, and website data, all from metadata
- `Website/`: the registry website, a Next.js static export built with shadcn/ui that reads only the generated `content/registry.json`; `npm run deploy` publishes it to Cloudflare Workers as static assets (`Website/wrangler.jsonc`), and `.github/workflows/pages.yml` can deploy the same export to GitHub Pages
- `Scripts/capture_previews.py`: per-item light and dark captures from the Showcase on the pinned simulator
- `Tests/RegistryKitTests/`: the tool's command, installer, validator, preset, MCP, and generator contracts, with the captured fixtures and the website codec check under `Fixtures/`

## View boundaries

Registry APIs use prepared display values, bindings for caller-controlled state, and action closures. `Text` inputs preserve caller-selected format styles and localization context. IDs and actions communicate selection without requiring a store, observable model, router, or persistence type

A component may own transient `@State` when its interaction is self-contained. State remains external when another view, a block, restoration, persistence, or product logic must coordinate it

Generic structural containers accept caller content with `@ViewBuilder`. Interactive appearance uses the matching SwiftUI style protocol. Independent optional behavior uses a focused `ViewModifier` instead of expanding the component initializer

A presentation choice a composed registry view owns follows the same placement rule as its primitives. The initializer carries what the view is: content, bindings, actions, and required accessibility input. A choice the view owns (variant, tone, tint, and any future size or emphasis) is a copy-and-return method on the view, `registry`-prefixed for discoverability and applied before generic SwiftUI modifiers, as in `InlineAlert("...") { }.registryVariant(.positive)`, `TransactionRow(...).registryTone(.negative)`, and `MacroProgress(...).registryTint(.orange)`; the method returns `Self` from a mutated copy and the default stays the initializer's former default. Native controls keep their presentation in a `registry` style (`.buttonStyle(.registryOutline)`), text treatments in a `registry` modifier with a variant argument (`registryBadge(.positive)`), the theme in the environment (`registryTheme(_:)`), and sizes through Apple's `controlSize`; a `ViewModifier` is for optional decorations that do not reach a component's internal layout

The composed block does not own a `ScrollView`, navigation container, or maximum width. Those are application composition decisions. The showcase demonstrates a readable iPad width at its call site

## Foundations

`RegistryTheme` is the set-up-once contract: an optional `accent`, the `onAccent` label color drawn on accent fills, `surface`, `border`, `positive`, `negative`, `disabledOpacity`, and `RegistryMetrics` (three spacings, control padding, two border widths, and the compact, control, and card radii). It is injected through SwiftUI `EnvironmentValues` with `@Entry`. The `registryTheme(_:)` modifier sets the environment and, when the theme declares an accent, applies it as the subtree tint, so Apple controls and registry items follow the same accent from one call at the scene root. A theme with `accent == nil` inherits the app tint already in place; the default never replaces a consumer's tint. The tint is applied conditionally because `tint(nil)` resets the tint rather than inheriting it (SwiftUICore implements it as `environment(\.tintColor, tint)` and keeps that key package-private), so a theme whose accent changes between `nil` and a value at runtime replaces the subtree and resets the state below it; apply the theme once before the scene appears, or pass `Color.accentColor` instead of `nil` when the accent must be switchable, as the Showcase's tuning panel does

Six presets (`system`, `graphite`, `indigo`, `rose`, `emerald`, `amber`) are plain `static let` values and starting points, not a theme engine. `graphite` is the ink-on-paper look: primary-colored accent with a background-colored label. `amber` is the light accent whose dark label proves `onAccent` earns its place

This is deliberately smaller than a full token system. Repeated colors and metrics use semantic tokens rather than hardcoded values, but a token enters foundations only after two real registry items need the exact same meaning (`everyFoundationTokenHasTwoSemanticConsumers` in `Tests/RegistryKitTests/RegistryContractTests.swift` names every token's two consumers). A style or modifier remains source-owned until two items use the exact same treatment

The Showcase's tuning panel is the theme creator, and it stays beside the catalog rather than on a tab of its own: an inspector column on iPad and, on iPhone, a sheet the catalog remains interactive under (`presentationBackgroundInteraction`), with the named accents in a strip above the tab bar (`tabViewBottomAccessory`), so a slider move shows on whichever demo is open. It offers every token as a live control, presets one tap away, Copy Swift for the exact `RegistryTheme` initializer to paste at a root, Copy Code for the theme as a preset code, and Import to load either back into the knobs. A custom accent can carry a separate dark value, exported as a dynamic `UIColor`. The panel's model lives in the Showcase, not in foundations, so the package stays a value type with no persistence

The theme preview is the `preview` block's wall. `ItemDemos`'s `theme-preview` case renders `PreviewWall`, so `capture_previews.py --themes` and `--preset` capture a screen of realistic product UI per preset rather than one representative strip, and the browsable `preview` block demo is that same view, so the tuning panel previews the wall live over it. The Create page and the Themes page show that wall's first screen per preset on iPhone 17, while the CSS token board stands in for a custom code that matches no preset

A preset code (`docs/registry-spec.md`, "Preset codes") is the theme as one short string that the website's Create page, the Showcase, `swiftui-registry preset`, and the MCP server all read and write; `swiftui-registry preset apply` turns it into `RegistryTheme+App.swift` for a consumer, and `capture_previews.py --preset` renders any code on the pinned simulator. The Create page shows the tokens as a CSS board and, when the code is one of the six presets, the real capture; it never claims to render SwiftUI

## Compatibility policy

Pre-1.0 foundations evolve by minor version: a patch release stays source compatible, a minor release may change the contract. Items therefore declare an `upToNextMinor` SwiftPM requirement from their known-good foundation floor, currently 0.1.0, the initial published contract (see `docs/registry-spec.md`). Copied source is verified against its declared platform floor and the recorded foundation range, and the install receipt records what was required at install time

## Installation behavior

The installer reads `Registry/registry.json`, resolves item dependencies depth first, validates safe relative paths, preflights target collisions, and copies exact source. It records item versions, registry and package dependency declarations, target paths, source digests, installed digests, and non-Swift base snapshots under the destination's `.swiftui-registry/` directory, and prints the actionable package instruction (source URL, SwiftPM requirement, and product) for the resolved closure

A repeated install skips only exact receipt-backed source. An untracked or modified target fails unless `--force` is explicit. The installer does not edit `.xcodeproj`, infer target membership, or add package dependencies. Xcode buildable folders make copied source straightforward in the showcase, but that behavior is not assumed for every consumer

Two read-only modes make installation inspectable. `--plan` runs the same resolution and preflight without writing: it prints the ordered dependency closure with versions and kinds, each target write with its status (`new`, `up-to-date`, `modified-would-require-force`, `would-merge`), the actionable package requirements, collisions, and the manual integration steps; a recipe prints its native guidance and installs nothing. `--diff` prints a `difflib` unified diff of each receipt-backed owned file against the canonical registry source and exits 0 on parity or 1 on differences, failing loudly when the receipt is missing. Both modes stay outside the installer's write path, so neither can mutate a destination

## Update policy

Copied source remains consumer-owned. `--update` uses the receipt's base content to distinguish upstream-only, local-only, and concurrent edits. Concurrent edits pass through `git merge-file`, an internal adapter behind the installer interface

A clean three-way merge becomes owned source and advances the recorded base to the incoming registry source. A conflict leaves all planned owned files unchanged and writes a reviewable `.merge` artifact. Update decisions are preflighted for the full dependency closure before source is written, so one conflicting file cannot silently produce a partial update

This policy proves conflict-aware evolution without making the registry authoritative over local edits

## Presentation policy

Three derived surfaces present the same metadata, and none is hand-edited: the markdown catalog under `docs/catalog/`, the website's data file `Website/content/registry.json` (every item with preview paths, install order, usage, source text, requirements, and the accessibility contract, plus the presets), and the Showcase manifest that drives the app's lists and usage snippets. Each has a byte-exact freshness test. The website itself is a Next.js app built with shadcn/ui components (sidebar, tabs, toggle group, command search, cards, tables) that renders that JSON into one page per item: preview first, one install command, the usage snippet, the source, and the details. It builds to a static export deployed to Cloudflare Workers, so no generated HTML is committed. Item images are captured from the Showcase's `-item` launch, cropped to the demo's reported frame, so a website preview is the same code a consumer installs, rendered on the same simulator the visual contract uses

## Discovery policy

`swiftui-registry search` is a deterministic adapter over the existing JSON. It filters kind and platform compatibility, requires every query term to match indexed metadata, and emits stable JSON results with the information an agent needs before installation

Search remains local; `swiftui-registry mcp` is a thin stdio adapter over the same engine so an agent inside a consuming app can search, plan, and install without leaving its editor. A hosted adapter becomes useful only when distribution, authentication, or catalog scale varies independently from local metadata

## Platform decision

Version 0 originally targeted iOS 18 and iPadOS through the iOS SDK to avoid an OS 26 requirement before the registry proved value. As of 2026-08-31 the owner reversed that decision: the registry targets iOS 26 and above. Items inherit Liquid Glass natively from the system, carry no pre-26 compatibility styling, and avoid 27-only APIs so the floor remains iOS 26. Runtime evidence currently comes from the iOS 27 simulator only; the machine carries no iOS 26 runtime, so floor-26 behavior is verified at compile time and 27-runtime execution. macOS, watchOS, tvOS, and visionOS are not declared by registry items yet

## Dependency direction

```text
Foundations <- Components <- Blocks <- Flows
```

Dependencies only point down. Registry source cannot import application architecture. Foundations cannot import registry items

## Rejected alternatives

- One monolithic UI package: undermines source ownership and progressive adoption
- Copy every foundation file with every item: creates duplicated theme contracts
- A production CLI before the product slices: would have validated packaging polish before product UI. The Stage 6 owner decision now authorizes the rewrite; status and evidence live in `docs/component-roadmap.md`
- Generic Button, Toggle, Slider, List, or navigation wrapper views: hide Apple primitives instead of styling them through native protocols and modifiers
- Mandatory TCA, MVVM, Observation model, or persistence type: leaks application architecture into presentation
