# Installation

Every command and snippet below is real: `swiftui-registry describe <item>` prints the same usage snippet the item's page shows, and `install --plan` prints the requirement you add.

## 1. Add the package

In `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/mangobyte-dev/swiftui-ui-registry.git", .upToNextMinor(from: "0.3.0"))
],
// In your target's dependencies:
.product(name: "SwiftUIRegistryFoundations", package: "swiftui-ui-registry")
```

In an Xcode project, choose File, Add Package Dependency, enter the same URL with the Up to Next Minor Version rule from 0.3.0, and add the `SwiftUIRegistryFoundations` product to the app target. The `package:` argument is the SwiftPM package identity for the URL, its last path component without `.git`.

## 2. Theme once

At the scene root:

```swift
import SwiftUIRegistryFoundations

ContentView()
    .registryTheme(.graphite)
```

Presets: `.system` (inherits your app tint), `.graphite`, `.indigo`, `.rose`, `.emerald`, `.amber`, and `.mango`, the sample design system. Every registry item below inherits the theme, and native controls follow the accent through the tint. To make your own, compose one on the [Create](/create/) page and paste its code, or tune it on the device (step 5).

## 3. Install an item

Install the tool with Homebrew, then install into a folder your target compiles:

```sh
brew install mangobyte-dev/tap/swiftui-registry
swiftui-registry install button --destination Sources/App/Components
```

The tool resolves the item's dependency closure, copies exact source (`RegistryButtonStyle.swift` here), writes `.swiftui-registry/receipt.json` beside it, and prints the package requirement: from 0.3.0 up to the next minor version, the floor every item declares. It never edits project files; make the destination folder a member of your build target. Outside a clone the tool fetches the registry snapshot of its own release tag on first use and caches it under `~/Library/Caches/swiftui-registry`.

## 4. Use it as the snippet says

```swift
Button("Save changes") {}
    .buttonStyle(.registry)

Button("Cancel") {}
    .buttonStyle(.registryOutline)
```

Apple's `Button` stays visible at the call site; the registry only styles it. Every item's page carries its snippet, its accessibility contract, and its full source.

## 5. Tune on the device

Add the `SwiftUIRegistryDesignSurface` product to the same target, import it, and apply `designSurface()` inside the theme call:

```swift
import SwiftUIRegistryDesignSurface

ContentView()
    .designSurface()
    .registryTheme(.graphite)
```

A debug build shows a draggable Tune button; the panel is a floating card over the live app. Tap Select, then any registry item, to scope the panel to the tokens that reach it; Copy Swift gives you the `RegistryTheme(...)` to paste back into step 2. A release build is unchanged. The [design surface](/docs/design-surface/) page has the whole tool.

## Update owned source later

```sh
swiftui-registry install button --destination Sources/App/Components --diff
swiftui-registry install button --destination Sources/App/Components --update
```

`--diff` shows your local edits against the registry source. `--update` is content-based: unmodified files take the registry version, your edits stay, disjoint edits merge with `git merge-file`, and overlapping edits keep your file and write a `.merge` artifact under `.swiftui-registry/conflicts/`. The updater never silently resolves a conflict or replaces a customized file.

## Requirements

- Swift tools 6.2 or newer, iOS 26 or newer, and an Xcode that builds Swift 6.2 packages
- Homebrew on macOS for the tool, or `swift run swiftui-registry <command>` from a clone
- Git when an update needs a three-way merge

The registry targets iOS 26 and above: items inherit Liquid Glass natively, carry no pre-26 compatibility styling, and avoid 27-only APIs so the floor stays iOS 26.
