# Showcase sample app

This universal iOS app is the compile, integration, and visual consumer for the registry, and the place to see and tune every item

The feature package depends only on `SwiftUIRegistryFoundations`. Product components and blocks under `Sources/SwiftUIRegistryShowcaseFeature/Installed/` are copied from the registry by `swiftui-registry install`; the receipt and non-Swift base snapshots live under `.swiftui-registry/` there

## What it shows

- Components, Blocks, Recipes: one searchable list per kind, generated from registry metadata (`RegistryCatalogManifest.swift`). Each item opens to its live demo, install command, usage snippet, and details. Demos are registered in `ItemDemos.swift` and compile each item's real usage snippet
- The tuning panel: the Tune button in the accent strip above the tab bar opens it as a floating card in the tool's own window over the catalog, every foundation token on a live control, with presets, appearance, text size, and right-to-left switches, and Copy Swift for the exact `RegistryTheme` to paste once at an app root. The tuned theme is applied at the catalog root, which is how a consuming app adopts the registry

## Launch arguments

- `-item <name>` renders one demo alone; `-appearance dark`, `-theme <preset>`, and `-capture-info <path>` drive `Scripts/capture_previews.py`
- `-default-tuning` ignores a persisted tuning; the UI suite always passes it
- `-stage-one` opens the Stage 1 fixture screen; `-accessibility-size`, `-right-to-left`, and `-empty-finance` remain for the UI tests

## Regenerate

From the repository root:

```sh
DEST=Examples/Showcase/SwiftUIRegistryShowcasePackage/Sources/SwiftUIRegistryShowcaseFeature/Installed
swift run swiftui-registry install activity-feed --destination "$DEST" --force
swift run swiftui-registry generate showcase-manifest
```

Build with the shared `SwiftUIRegistryShowcase` scheme in `SwiftUIRegistryShowcase.xcworkspace`. Run the UI suite on the iPhone 17 iOS 27.0 simulator for the pinned visual contract (`docs/visual-testing.md`)
