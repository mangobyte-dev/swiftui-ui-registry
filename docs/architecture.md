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
- `Examples/Showcase/`: a real iOS consumer and visual harness
- `Tests/RegistryTests/`: registry and overwrite behavior

## View boundaries

Registry APIs use prepared display values, bindings for caller-controlled state, and action closures. `Text` inputs preserve caller-selected format styles and localization context. IDs and actions communicate selection without requiring a store, observable model, router, or persistence type

A component may own transient `@State` when its interaction is self-contained. State remains external when another view, a block, restoration, persistence, or product logic must coordinate it

Generic structural containers accept caller content with `@ViewBuilder`. Interactive appearance uses the matching SwiftUI style protocol. Independent optional behavior uses a focused `ViewModifier` instead of expanding the component initializer

The composed block does not own a `ScrollView`, navigation container, or maximum width. Those are application composition decisions. The showcase demonstrates a readable iPad width at its call site

## Foundations

`RegistryTheme` provides semantic surface, border, positive, and negative colors plus four layout metrics. It is injected through SwiftUI `EnvironmentValues` with `@Entry`. The app's native tint remains the source for interactive accent color

This is deliberately smaller than a full token system. Repeated colors and metrics use semantic tokens rather than hardcoded values, but a token enters foundations only after two real registry items need the exact same meaning. A style or modifier remains source-owned until two items use the exact same treatment

## Installation behavior

The installer reads `Registry/registry.json`, resolves item dependencies depth first, validates safe relative paths, preflights target collisions, and copies exact source. It records item versions, dependency declarations, target paths, source digests, installed digests, and non-Swift base snapshots under the destination's `.swiftui-registry/` directory

A repeated install skips only exact receipt-backed source. An untracked or modified target fails unless `--force` is explicit. The installer does not edit `.xcodeproj`, infer target membership, or add package dependencies. Xcode buildable folders make copied source straightforward in the showcase, but that behavior is not assumed for every consumer

## Update policy

Copied source remains consumer-owned. `--update` uses the receipt's base content to distinguish upstream-only, local-only, and concurrent edits. Concurrent edits pass through `git merge-file`, an internal adapter behind the installer interface

A clean three-way merge becomes owned source and advances the recorded base to the incoming registry source. A conflict leaves all planned owned files unchanged and writes a reviewable `.merge` artifact. Update decisions are preflighted for the full dependency closure before source is written, so one conflicting file cannot silently produce a partial update

This policy proves conflict-aware evolution without making the registry authoritative over local edits

## Discovery policy

`Scripts/search.py` is a deterministic adapter over the existing JSON. It filters kind and platform compatibility, requires every query term to match indexed metadata, and emits stable JSON results with the information an agent needs before installation

Search remains a local script because the current catalog does not justify network hosting or an MCP seam. A hosted adapter becomes useful only when distribution, authentication, or catalog scale varies independently from local metadata

## Platform decision

Version 0 targets iOS 18 and iPadOS through the iOS SDK. This keeps `@Entry`, modern previews, and current SwiftUI composition while avoiding an OS 26 or 27 requirement before the registry proves value. macOS, watchOS, tvOS, and visionOS are not declared by registry items yet

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
