# SwiftUIRegistry

A native-first registry of SwiftUI product UI that you copy into your app and own, in the spirit of shadcn/ui. The unit of distribution is understandable Swift source plus machine-readable metadata, not a framework: set the theme once, search a local catalog, inspect the install plan, copy the code, customize it, and audit updates later through a receipt-backed three-way merge. Apple controls stay visible at the call site

Browse it three ways:

- The website: `Website/`, a Next.js static site built with shadcn/ui. Every item has a page that leads with its rendered preview in light and dark, one install command, the usage snippet, and the full source. Live at https://swiftui-registry.mangobytekw.workers.dev (Cloudflare Workers static assets, `cd Website && npm run deploy`); run it locally with `cd Website && npm ci && npm run dev`
- The Showcase app: `Examples/Showcase/SwiftUIRegistryShowcase.xcworkspace`. Components, Blocks, and Recipes tabs with a live demo per item, and a Tune tab that turns every foundation token into a slider beside a preview and exports the Swift to paste
- The markdown catalog: [docs/catalog/index.md](docs/catalog/index.md)

## Taxonomy

Three item kinds, enforced by a single validator:

- `component`: an installable style, focused modifier, or small composition that adds a meaningful reusable treatment to a native control, such as `button`, `input`, `card`, or `avatar`
- `block`: an installable, architecture-neutral composition of components, such as `auth-form` or `activity-feed`
- `recipe`: native guidance where a one-line Apple API is the entire treatment, such as `switch`, `sheet`, or `context-menu`; nothing installs

The value gate: an installable item must add a meaningful reusable treatment or composition beyond a native API. A wrapper that merely renames an Apple control ships as a recipe instead (`docs/registry-spec.md`)

## Set up once, use it everywhere

1. Add the `SwiftUIRegistryFoundations` package product (SwiftPM snippet below, or File > Add Package Dependency in Xcode)
2. Apply a theme at your scene root. Every registry item below inherits it, and native controls follow the accent through the tint:

   ```swift
   ContentView()
       .registryTheme(.graphite)
   ```

   Presets: `.system` (inherits your app tint), `.graphite`, `.indigo`, `.rose`, `.emerald`, `.amber`. To make your own, open the Showcase's Tune tab, move the sliders, and tap Copy Swift; it exports the exact `RegistryTheme(...)` initializer

3. Install items with the `swiftui-registry` tool from a clone of this repository. From the root of that clone, `swift run swiftui-registry <command>` builds and runs it; or build it once with `swift build -c release`, put `.build/release/swiftui-registry` on your PATH, and pass `--registry /path/to/clone` from anywhere:

   ```sh
   swift run swiftui-registry search activity --kind block --format names
   swift run swiftui-registry install activity-feed --destination path/to/YourTarget/Components --plan
   swift run swiftui-registry install activity-feed --destination path/to/YourTarget/Components
   ```

   The installer resolves the dependency closure, copies exact source, writes `.swiftui-registry/receipt.json`, and prints the package requirement. It never edits project files; make the destination folder a member of your build target

4. Compose through the item's public API; the exact snippet is on its catalog page and in the Showcase

## Status

Version 0, an honest prototype:

- 50 items: 26 installable components, 6 blocks, and 18 recipes, generated into `docs/catalog/` and the website's data file
- `SwiftUIRegistryFoundations` is a small pre-1.0 package: accent, on-accent, surface, border, positive, negative, disabled opacity, and metrics, with six presets and one root modifier
- Every item carries versioned JSON metadata: dependencies, actionable SwiftPM requirements, platforms, accessibility notes, previews, captured screenshots, and a usage snippet, all checked by one validator
- The installer writes exact-content receipts and performs conflict-aware three-way updates
- The Showcase compiles every installable item and every recipe snippet at the iOS 26 floor, with pinned visual contract checks for the blocks and an accessibility-audited demo walk over all 50 items
- Not yet: hosted registry, Xcode project mutation, platforms beyond iOS, a Homebrew formula, or a published version tag. Stage status and open deferrals live in one place, `docs/component-roadmap.md`, Current state

## Showcase screenshots

| Activity feed (Stage 3) | Authentication (Stage 2) | Finance (Stage 1) |
| --- | --- | --- |
| ![Activity feed](docs/images/items/activity-feed-light.png) | ![Authentication form](docs/images/items/auth-form-light.png) | ![Finance overview](docs/images/items/finance-overview-light.png) |

| Button | Alert | Item row |
| --- | --- | --- |
| ![Button variants](docs/images/items/button-light.png) | ![Inline alert](docs/images/items/alert-light.png) | ![Item rows](docs/images/items/item-light.png) |

Dark captures sit beside every light one under `docs/images/items/`, and the website switches between them

## Discover

Search is local, deterministic, and JSON-first:

```sh
swiftui-registry search nutrition dashboard \
  --kind block \
  --platform iOS \
  --target-version 26.0
```

Results include dependency closure inputs, package requirements, accessibility notes, preview paths, and compatibility metadata. Search does not require a model, MCP server, account, or hosted registry. Every `swiftui-registry` command below runs as `swift run swiftui-registry ...` from the root of a clone, or as the built binary with `--registry /path/to/clone`

## Install

The consumer first adds the `SwiftUIRegistryFoundations` package product. In a SwiftPM consumer, copy this into `Package.swift`:

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/mangobyte-dev/swiftui-ui-registry.git", .upToNextMinor(from: "0.1.0"))
]

// In the consuming target's dependencies:
.product(name: "SwiftUIRegistryFoundations", package: "swiftui-ui-registry")
```

The `package:` argument is the SwiftPM package identity for the URL, its last path component without `.git`. In an Xcode app project instead, choose File > Add Package Dependency, enter the same URL with the Up to Next Minor Version rule from 0.1.0, and add the `SwiftUIRegistryFoundations` product to your app target. Then run:

```sh
swiftui-registry install finance-overview \
  --destination path/to/YourTarget/Components
```

The installer resolves `metric-card`, `transaction-row`, and `empty` before copying `finance-overview`. It writes `.swiftui-registry/receipt.json` and non-Swift base snapshots inside the destination. A repeated install is accepted only when the existing source still matches its receipt. `--force` is required to replace modified owned source

Verify the install by building the consuming target for an iOS Simulator destination, for example `xcodebuild -scheme YourApp -destination 'generic/platform=iOS Simulator' build`

## Update owned source

```sh
swiftui-registry install finance-overview \
  --destination path/to/YourTarget/Components \
  --update
```

Update behavior is content-based:

- Unmodified local source receives the registry version
- Local-only edits remain unchanged
- Disjoint local and registry edits are merged with `git merge-file`
- Overlapping edits preserve the owned source and emit a `.merge` artifact under `.swiftui-registry/conflicts/`

The updater never silently resolves a conflict or replaces a customized file

## Agent workflow

Both inspection flags are read-only and write nothing, so an agent can preview and audit an installation before touching the destination:

```sh
swiftui-registry install finance-overview \
  --destination path/to/YourTarget/Components \
  --plan
```

`--plan` resolves the item like a real install and prints the ordered dependency closure with versions and kinds, every target write with its status (`new`, `up-to-date`, `modified-would-require-force`, `would-merge`), the actionable package requirements, preflight collisions, and the manual integration steps. For a recipe it prints the native guidance and states nothing installs

```sh
swiftui-registry install finance-overview \
  --destination path/to/YourTarget/Components \
  --diff
```

`--diff` prints a unified diff of each receipt-backed owned file against the canonical registry source. It exits 0 when every file is identical and 1 when differences exist, and it requires an existing installation receipt. Run it before `--update` to see exactly what local customization is at stake

### MCP server

`swiftui-registry mcp` exposes the same operations (search, describe, plan, diff, install, plus the preset tools) as MCP tools over stdio. Build the tool once with `swift build -c release` in your clone, then register the binary in your MCP client, for example Claude Code's `.mcp.json`:

```json
{
  "mcpServers": {
    "swiftui-registry": {
      "command": "/path/to/swiftui-cn/.build/release/swiftui-registry",
      "args": ["mcp", "--registry", "/path/to/swiftui-cn"]
    }
  }
}
```

The read-only tools carry `readOnlyHint`; `install_item` carries `destructiveHint` so clients prompt before it writes. Recipes report native guidance and install nothing

## Compose

```swift
ActivityFeed(
    "Activity",
    notice: ActivityNotice("Card delivery delayed", message: Text("Arrives Thursday.")),
    onDismissNotice: { },
    items: items,
    earlierItems: earlier,
    isLoading: isLoading,
    onSelect: onSelect
)
```

The block owns presentation composition. The caller owns value preparation, localization catalogs, navigation, state, persistence, scrolling, and container width

## Sample app

```sh
open Examples/Showcase/SwiftUIRegistryShowcase.xcworkspace
```

Select the `SwiftUIRegistryShowcase` scheme and run. The Components, Blocks, and Recipes tabs list every item from the generated manifest and open a live demo, the install command, and the usage snippet; the Tune tab is the theme creator. The app consumes the exact source installed under `Examples/Showcase/SwiftUIRegistryShowcasePackage/Sources/SwiftUIRegistryShowcaseFeature/Installed/`

## Verify

```sh
swift run swiftui-registry validate
swift run swiftui-registry generate catalog
swift run swiftui-registry generate showcase-manifest
swift run swiftui-registry generate site-data
swift test
xcodebuildmcp simulator test \
  --workspace-path Examples/Showcase/SwiftUIRegistryShowcase.xcworkspace \
  --scheme SwiftUIRegistryShowcase \
  --simulator-id YOUR_IOS_27_IPHONE_SIMULATOR_ID
```

The simulator suite walks every item's demo, verifies the blocks' behavior (focus order, disabled states, validation copy, bindings, placeholder states, accordion, notice dismissal), the empty state, accessibility-size typography, right-to-left mirroring, the tuning export, and approved visual references. Baseline policy is documented in `docs/visual-testing.md`. Item screenshots are captured with `python3 Scripts/capture_previews.py`

## Requirements

- Swift tools 6.2 or newer
- iOS 26 or newer
- Xcode capable of building Swift 6.2 packages
- Node 22 for the website and for the website codec check inside `swift test`
- Python 3 only for `Scripts/capture_previews.py`, the maintainer's simulator capture script
- Git when an update needs a three-way merge

The repository is currently verified with Xcode 27.0 and Swift 6.4. The registry targets iOS 26 and above: items inherit Liquid Glass natively, carry no pre-26 compatibility styling, and intentionally avoid 27-only APIs so the floor remains iOS 26

## Read next

- [Website source](Website/) and the [item catalog](docs/catalog/index.md)
- [Philosophy](docs/philosophy.md)
- [Architecture](docs/architecture.md)
- [Component roadmap](docs/component-roadmap.md)
- [Research](docs/research.md)
- [Registry specification](docs/registry-spec.md)
- [Visual testing](docs/visual-testing.md)
- [Contributing](CONTRIBUTING.md)

## Deliberate boundaries

Version 0 does not edit Xcode projects, add package dependencies, or host registry content. It also does not claim macOS, watchOS, tvOS, visionOS, or physical-device verification. Those boundaries keep the experiment focused on product composition, source ownership, deterministic discovery, and safe updates

## Security and conduct

Report vulnerabilities privately as described in [SECURITY.md](SECURITY.md); never in a public issue. Participation follows [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md). CI runs the registry gate, the website build with a production dependency audit, and a secret scan on every push and pull request

## License

MIT
