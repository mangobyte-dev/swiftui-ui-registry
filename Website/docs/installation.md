# Installation

## 1. Add the package

In `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/mangobyte-dev/swiftui-ui-registry.git", .upToNextMinor(from: "0.3.0"))
],
// In your target's dependencies:
.product(name: "SwiftUIRegistryFoundations", package: "swiftui-ui-registry")
```

In an Xcode project:

1. Choose File, then Add Package Dependency.
2. Enter the same URL. Set the rule to Up to Next Minor Version from 0.3.0.
3. Add the `SwiftUIRegistryFoundations` product to the app target.

The `package:` argument is the SwiftPM package identity for the URL. It is the last path component without `.git`.

## 2. Theme once

At the scene root:

```swift
import SwiftUIRegistryFoundations

ContentView()
    .registryTheme(.graphite)
```

Presets: `.system` (inherits your app tint), `.graphite`, `.indigo`, `.rose`, `.emerald`, `.amber`, and `.mango`, the sample design system. Every registry item below inherits the theme. Native controls follow the accent through the tint. To make your own theme, compose one on the [Create](/create/) page and paste its code, or tune it on the device (step 5).

## 3. Install an item

Install the tool with Homebrew. Then install an item into a folder your target compiles:

```sh
brew install mangobyte-dev/tap/swiftui-registry
swiftui-registry install button --destination Sources/App/Components
```

The tool does four things:

- It resolves the item's dependency closure.
- It copies exact source (`RegistryButtonStyle.swift` here).
- It writes `.swiftui-registry/receipt.json` beside it.
- It prints the package requirement: from 0.3.0 up to the next minor version, the floor every item declares.

The tool never edits project files. Make the destination folder a member of your build target. Outside a clone, the tool fetches the registry snapshot of its own release tag on first use. It caches the snapshot under `~/Library/Caches/swiftui-registry`.

## 4. Use it as the snippet says

```swift
Button("Save changes") {}
    .buttonStyle(.registry)

Button("Cancel") {}
    .buttonStyle(.registryOutline)
```

Apple's `Button` stays visible at the call site. The registry only styles it. Every item's page carries its snippet, its accessibility contract, and its full source.

## 5. Tune on the device

Add the `SwiftUIRegistryDesignSurface` product to the same target. Import it. Apply `designSurface()` inside the theme call:

```swift
import SwiftUIRegistryDesignSurface

ContentView()
    .designSurface()
    .registryTheme(.graphite)
```

A debug build shows a draggable Tune button. The panel is a floating card over the live app. To scope the panel to the tokens that reach an item, tap Select, then tap any registry item. Copy Swift gives you the `RegistryTheme(...)` to paste back into step 2. A release build is unchanged. The [design surface](/docs/design-surface/) page has the whole tool.

## Update owned source later

```sh
swiftui-registry install button --destination Sources/App/Components --diff
swiftui-registry install button --destination Sources/App/Components --update
```

`--diff` shows your local edits against the registry source. `--update` is content-based:

- Unmodified files take the registry version.
- Your edits stay.
- Disjoint edits merge with `git merge-file`.
- Overlapping edits keep your file and write a `.merge` artifact under `.swiftui-registry/conflicts/`.

The updater never silently resolves a conflict or replaces a customized file.

## Requirements

- Swift tools 6.2 or newer, iOS 26 or newer, and an Xcode that builds Swift 6.2 packages
- Homebrew on macOS for the tool, or `swift run swiftui-registry <command>` from a clone
- Git when an update needs a three-way merge

The registry targets iOS 26 and above:

- Items inherit Liquid Glass natively.
- Items carry no pre-26 compatibility styling.
- Items avoid 27-only APIs, so the floor stays iOS 26.
