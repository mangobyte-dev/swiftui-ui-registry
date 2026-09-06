# Todo Counter sample app

A consumer built from a fresh Xcode project to prove the registry works with any architecture: the Composable Architecture drives a todo list and Point-Free's counter, and every visible control is a native SwiftUI control styled by registry items this app owns

| Todos | Counter |
| --- | --- |
| ![Todos tab with a completed task](Screenshots/todos.jpg) | ![Counter tab at seven](Screenshots/counter.jpg) |

Captured on the iPhone 17 simulator, iOS 27, on 2026-09-06

What it exercises, in the order it was built on 2026-09-06:

- The published package by URL: `TodoCounterPackage/Package.swift` depends on `swiftui-ui-registry` at `0.1.0` (up to the next minor) and on `swift-composable-architecture` `1.26.2`
- The released tool: `brew install mangobyte-dev/tap/swiftui-registry`, then `swiftui-registry install button input card checkbox badge empty separator` (one call per item) into `TodoCounterPackage/Sources/TodoCounterFeature/Registry`, which carries the receipt under `.swiftui-registry/`
- A theme the shadcn way: `swiftui-registry preset apply a13GkaOXWwIF` wrote `RegistryTheme+App.swift`; the app then edited it (a custom coral accent, larger radii, a slightly stronger surface) and `swiftui-registry preset resolve` read the edit back into the shareable code `a2nH36tnmJHJAMzm`, which the website's Create page opens
- A component the app owns: `RegistryBadge.swift` gained uppercase, semibold labels. `swiftui-registry install badge --diff` prints the hunk, `--plan` reports `modified-would-require-force`, and `--update` keeps the edit as `locally-modified`
- App-wide typography with `fontDesign(.rounded)` at the root, beside `registryTheme(.app)`
- The MCP server: `swiftui-registry mcp` answered `initialize`, `tools/list`, `search_items`, `describe_item`, `plan_install`, `diff_item`, and `describe_preset` over stdio from this directory

## Run

Open `TodoCounter.xcworkspace`, select the `TodoCounter` scheme, and run on an iOS 26 or newer simulator. Xcode resolves both packages from GitHub on first build. The test plan runs the feature's `TestStore` tests and one UI test that adds, completes, and counts through the registry-styled controls

## Layout

- `TodoCounter/`: the app shell, which creates one store and hands it to `ContentView`
- `TodoCounterPackage/Sources/TodoCounterFeature/`: `Todos`, `Counter`, and the `TodoCounter` root reducer, their views, and `Registry/` with the installed items, the theme file, and the receipt
- `TodoCounterPackage/Tests/`: reducer tests
- `TodoCounterUITests/`: the simulator flow
