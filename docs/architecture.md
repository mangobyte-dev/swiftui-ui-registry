# Architecture

## Decision

Version 0 uses a hybrid distribution model:

```text
consumer app
├── depends on SwiftUIRegistryFoundations
└── owns copied component and block source
```

The package boundary is intentionally shallow. `SwiftUIRegistryFoundations` contains only the stable environment contract and one shared surface modifier. Registry components and blocks are not package products

## Why this split

Foundations need one coherent update path across copied items. Product UI needs local modification, domain naming, and close integration with an app. Copying both would duplicate the foundation contract; packaging both would turn local product composition into a framework API compatibility problem

This is a hypothesis exercised by finance and nutrition, not a claim of universal reuse. A future item with no foundation dependency should be allowed

## Source tree

- `Sources/SwiftUIRegistryFoundations/`: stable package API
- `Registry/items/`: machine-readable item declarations
- `Registry/sources/components/`: canonical copied styles, focused modifiers, and reusable compositions
- `Registry/sources/blocks/`: canonical copied block source
- `Scripts/install.py`: dependency resolution, receipts, installation, and conflict-aware updates
- `Scripts/search.py`: deterministic developer and agent discovery over registry metadata
- `Examples/Showcase/`: a real iOS consumer, a browsable catalog with a demo per item, the theme tuning panel, and the capture route for item screenshots
- `Scripts/generate_catalog.py`, `Scripts/generate_showcase_manifest.py`, `Scripts/generate_site_data.py`: the derived catalog, Showcase manifest, and website data, all from metadata
- `Website/`: the registry website, a Next.js static export built with shadcn/ui that reads only the generated `content/registry.json`; `npm run deploy` publishes it to Cloudflare Workers as static assets (`Website/wrangler.jsonc`), and `.github/workflows/pages.yml` can deploy the same export to GitHub Pages
- `Scripts/capture_previews.py`: per-item light and dark captures from the Showcase on the pinned simulator
- `Tests/RegistryTests/`: registry and overwrite behavior

## View boundaries

Registry APIs use prepared display values, bindings for caller-controlled state, and action closures. `Text` inputs preserve caller-selected format styles and localization context. IDs and actions communicate selection without requiring a store, observable model, router, or persistence type

A component may own transient `@State` when its interaction is self-contained. State remains external when another view, a block, restoration, persistence, or product logic must coordinate it

Generic structural containers accept caller content with `@ViewBuilder`. Interactive appearance uses the matching SwiftUI style protocol. Independent optional behavior uses a focused `ViewModifier` instead of expanding the component initializer

The composed block does not own a `ScrollView`, navigation container, or maximum width. Those are application composition decisions. The showcase demonstrates a readable iPad width at its call site

## Foundations

`RegistryTheme` is the set-up-once contract: an optional `accent`, the `onAccent` label color drawn on accent fills, `surface`, `border`, `positive`, `negative`, `disabledOpacity`, and `RegistryMetrics` (three spacings, control padding, two border widths, and the compact, control, and card radii). It is injected through SwiftUI `EnvironmentValues` with `@Entry`. The `registryTheme(_:)` modifier sets the environment and, when the theme declares an accent, applies it as the subtree tint, so Apple controls and registry items follow the same accent from one call at the scene root. A theme with `accent == nil` inherits the app tint already in place; the default never replaces a consumer's tint

Six presets (`system`, `graphite`, `indigo`, `rose`, `emerald`, `amber`) are plain `static let` values and starting points, not a theme engine. `graphite` is the ink-on-paper look: primary-colored accent with a background-colored label. `amber` is the light accent whose dark label proves `onAccent` earns its place

This is deliberately smaller than a full token system. Repeated colors and metrics use semantic tokens rather than hardcoded values, but a token enters foundations only after two real registry items need the exact same meaning (`Tests/RegistryTests/test_installer.py` names every token's two consumers). A style or modifier remains source-owned until two items use the exact same treatment

The Showcase's Tune tab is the theme creator: every token as a live control beside a preview of the registry, presets one tap away, and Copy Swift for the exact `RegistryTheme` initializer to paste at a root. The panel's model lives in the Showcase, not in foundations, so the package stays a value type with no persistence

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

`Scripts/search.py` is a deterministic adapter over the existing JSON. It filters kind and platform compatibility, requires every query term to match indexed metadata, and emits stable JSON results with the information an agent needs before installation

Search remains a local script; `Scripts/mcp_server.py` is a thin stdio adapter over the same code so an agent inside a consuming app can search, plan, and install without leaving its editor. A hosted adapter becomes useful only when distribution, authentication, or catalog scale varies independently from local metadata

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
- A production CLI now: validates packaging polish before validating product UI
- Generic Button, Toggle, Slider, List, or navigation wrapper views: hide Apple primitives instead of styling them through native protocols and modifiers
- Mandatory TCA, MVVM, Observation model, or persistence type: leaks application architecture into presentation
