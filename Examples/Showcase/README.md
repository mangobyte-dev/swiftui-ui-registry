# Showcase sample app

Universal iOS app: compile/integration/visual consumer for registry; tune every item.

Feature package depends only on `SwiftUIRegistryFoundations`; `swiftui-registry install` copies components/blocks into `Sources/SwiftUIRegistryShowcaseFeature/Installed/`, receipt/non-Swift snapshots: `.swiftui-registry/`.

## What it shows

- Components, Blocks, Recipes: searchable list per kind (`RegistryCatalogManifest.swift`); demo, install command, usage snippet, details; `ItemDemos.swift` compiles each item's real usage snippet
- Tuning panel: Tune opens floating card, tool's own window; every foundation token live-tunable (presets, appearance, text size, right-to-left); Copy Swift: `RegistryTheme`, paste once at app root; applied at catalog root (adoption pattern)

## Launch arguments

- `-item <name>`: one demo alone; `-appearance dark`, `-theme <preset>`, `-capture-info <path>`: `Scripts/capture_previews.py`
- `-default-tuning`: skips persisted tuning; UI suite always passes it
- `-stage-one`: Stage 1 fixture; `-accessibility-size`, `-right-to-left`, `-empty-finance`: UI tests

## Regenerate

From repository root:

```sh
DEST=Examples/Showcase/SwiftUIRegistryShowcasePackage/Sources/SwiftUIRegistryShowcaseFeature/Installed
swift run swiftui-registry install activity-feed --destination "$DEST" --force
swift run swiftui-registry generate showcase-manifest
```

Build shared `SwiftUIRegistryShowcase` scheme in `SwiftUIRegistryShowcase.xcworkspace`; UI suite: iPhone 17 iOS 27.0 (`docs/visual-testing.md`).
