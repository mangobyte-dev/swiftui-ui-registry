# Changelog

## 0.3.0 (public beta)

The design surface tunes a running app on the device. It ships as a second package product. To install or upgrade, run `brew install mangobyte-dev/tap/swiftui-registry` or `brew upgrade swiftui-registry`.

### Added

- The `SwiftUIRegistryDesignSurface` product. Add it, `import SwiftUIRegistryDesignSurface`, and apply `designSurface()` inside the app's `registryTheme(_:)`. In a debug build, the product adds a draggable Tune button and a floating, movable, resizable panel in the tool's own window. The window sits over the whole app, which stays live underneath on every tab, sheet, and cover. A release build returns the content unchanged. The tuned tokens persist as `registry-tokens.json` in the app's Documents directory. Export them as a preset code that any registry tool applies, or as Swift to paste.
- Tap-to-select. Select arms the next tap. The panel then scopes to the tokens that reach the item you tapped, outlines every tagged item on the screen with its name, and lists them under On this screen. `ItemSelection.chain` names every item under the pick, innermost first. A host can offer the row around a button as well as the button. A pick on nothing clears the selection.
- Host tokens. Conform an app's own token value to `TokenDocument`, which holds a shipped value, a file name, and pages of `.number`, `.choice`, and `.color` knobs with an `apply()`. Pass it to `designSurface(tokens:)`. The panel then gains an App tokens section that writes changes back to the app.
- Per-item knobs. Register numeric knobs with `designSurface(knobs:)` (`ItemKnob`). Read them inside an item with `registryKnob(_:_:default:)`. They persist beside the tokens in `design-knobs.json`. The product writes only a value that moved.
- The host-hooks overload `designSurface(enabled:tunesRegistryTheme:knobs:itemTitle:page:panelEnvironment:panel:)` serves an app that paints registry items from its own tokens. It compiles in every build configuration. The parameters:
    - `enabled` is the app's own switch.
    - `tunesRegistryTheme: false` drops the panel's theme sections.
    - `panel` adds the app's sections.
    - `page` pushes the app's page for a picked item.
    - `panelEnvironment` wraps the panel's stack.
    - `itemTitle` names rows and outlines.
- Foundations gained `registryItem(_:)` and `registryScreen(_:)`, the tags the surface selects and names screens by. It also gained the surface reporter and the per-item knobs in the environment. All are inert without a surface.
- A fourth generator, `swiftui-registry generate item-tokens`, writes the item-to-token map the design surface scopes its panel by. CI checks it for drift with the other generated outputs.
- Three new documents: `CHANGELOG.md` (this file), a repository-layout table in `CONTRIBUTING.md`, and `docs/RELEASE-CHECKLIST.md`, the list a release closes line by line.

### Changed

- The tuning panel moved out of the Showcase into the `SwiftUIRegistryDesignSurface` product. The Showcase consumes it. The panel is a floating card in the tool's own window, not the earlier sheet or inspector column. It behaves as follows:
    - A drag bar moves it.
    - A corner grip resizes it.
    - A chevron collapses it.
    - It can hang off the leading, trailing, and bottom edges while its grab strip stays inside the safe area.
    - It never goes above the top.
    - A drag against the trailing edge of an iPad snaps it into a full-height column.
    - The product remembers its frame per size class and re-clamps it on rotation.
- The tool's own chrome (the Tune button, the card, the selection ring, the outlines, the guides) uses fixed system values, never the tuned theme. Tuning the app never restyles the tool. The tool's motion is off under Reduce Motion.
- Every installable item declares the `0.3.0` foundations floor, because every one applies `registryItem(_:)`. The installer prints `from 0.3.0 up to the next minor version`.
- swift-sharing is pinned to the 2.9.x line (from `2.9.1`, below `2.10.0`) with no traits declared. A consumer that already resolves xctest-dynamic-overlay is not forced onto a newer major.
- The repository holds only what an adopter needs. Planning, research, and run logs left it.

### Fixed

- The tool no longer advertises an older Homebrew tag as an update. The notice appears only for a tag newer than the running tool.
- A tap on a List row under the card pushes again. The key window now follows the text field that takes focus: a field in the app takes the keyboard, and a field in the panel takes it back. Before, the key window switched during hit testing, which cancelled the touch.
- The collapse control has its own accessibility frame. The drag runs over the whole bar as a simultaneous gesture.
- The card is clamped into the window's safe area. Its strip never sits under the status bar and never stops short of it.
- Edge cases now behave correctly:
    - A knob with a non-positive step or a shipped value outside its range is made usable and logged.
    - A token file that fails to decode (edited by hand, or written by a newer version) leaves the shipped values in place, is logged once, and is not rewritten until a knob moves.
    - A choice knob keeps a value its options no longer list.
    - An empty item or screen name tags nothing.
    - A host title that is an empty string falls back to the item's name.
    - Ties between equal frames resolve by name.
    - An item scrolled off the screen is not listed as on it.
- Foundations compiles on macOS again; `Color(uiColor:)` had crept into the selection ring. An unused anchor preference left the public API before it shipped.

### Known limitations

- Two visual references, `auth-light` and `nutrition-light`, are stale after the tuning-strip change. They measure 2.70 percent and 1.54 percent against the 1.5 percent tolerance. They are recaptured but await the owner's copy into `ReferenceImages/`. Until then, those two Showcase UI tests fail (`docs/visual-testing.md`).
- The iPad simulator sometimes never reports idle after keyboard input. Therefore the UI suite passes `-disable-animations` on the iPad destination, and one test records a measured skip rather than a failure (`docs/visual-testing.md`).
- The tool's window installs over the first connected scene. A second window of the same app on iPad is not covered.
- Items installed from `0.1.0` or `0.2.0` carry no `registryItem(_:)` tag. Select and the outlines find nothing in them until `swiftui-registry install <item> --update` brings the tagged sources.
- The Showcase is portrait-only on iPhone. Rotation of the card runs on the iPad destination and in the host apps.

## 0.2.0 (2026-09-07)

The Stage 7 release. To install or upgrade, run `brew install mangobyte-dev/tap/swiftui-registry` or `brew upgrade swiftui-registry`.

### Added

- Sixteen items, which grow the catalog from 57 to 73:
    - Six chat and feedback components (`attachment`, `bubble`, `marker`, `message`, `message-scroller`, `toast`).
    - Seven recipes (`carousel`, `chart-tooltip`, `date-picker`, `input-otp`, `menubar`, `sheet`, `typography`).
    - Three blocks (`dashboard`, `signup-form`, `questionnaire`).
- `describe <item>` prints an item's metadata, usage snippet, accessibility contract, install order, package requirement, and files (`--source`, `--format json`). `info --destination <dir>` reports every owned file as up-to-date, modified, or missing through the receipt.
- Preset code format version `b`. After the version `a` fields and the custom accent block, a code can carry the font design, a surface step for a four-level elevation ladder, a chart palette, and optional light and dark pairs for the background, foreground, and secondary foreground. A code stays `a` whenever nothing appended leaves its default. Every existing code still decodes to the same theme.
- The `SwiftUIRegistryFoundations` 0.2.0 API, all defaulted so existing initializers compile:
    - `fontDesign`, `surfaceOpacity`, `surfaceStep`, `chartPalette`, `background`, `foreground`, and `secondaryForeground` on `RegistryTheme`.
    - The `mango` preset, the sample design system, documented in `docs/mango.md`.
    - `RegistrySurfaceLevel` with `registrySurface(level:)`.
- Three agent skills under `Skills/` for consuming, theming, and authoring the registry, mirrored to `~/.claude/skills/`.
- iPad Pro 13-inch captures of every item, light and dark. The website shows both idioms.

### Changed

- Registry styles keep the iPadOS pointer effect (`button`, `checkbox`, `accordion`, `breadcrumb`). The sidebar recipe adds the `sidebarAdaptable` tab view.
- The `chart` item reads the chart palette and declared the 0.2.0 foundations floor. Every other item kept 0.1.0 at this release.

## 0.1.0 (2026-09-06)

The first published contract of the SwiftUI registry.

### Added

- 57 source-owned items (31 components, 8 blocks, 18 recipes), the `SwiftUIRegistryFoundations` theme package, and the `swiftui-registry` tool.
- The tool installs items with receipt-backed three-way updates, searches the catalog, validates it, reads and writes preset codes, serves the same operations over MCP, and generates the catalog, the Showcase manifest, and the website data. Outside a clone, it fetches this tag's registry snapshot on first use.
- The release workflow attaches `swiftui-registry-macos-universal.tar.gz` (arm64 and x86_64) and its `.sha256` for the Homebrew tap.
- The `TodoCounter` example, a second consumer built on the Composable Architecture.
