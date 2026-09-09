# Changelog

## 0.3.0 (public beta)

The design surface tunes a running app on the device. It ships as a second package product. Install or upgrade: `brew install mangobyte-dev/tap/swiftui-registry` or `brew upgrade swiftui-registry`.

### Added

- `SwiftUIRegistryDesignSurface`. Add the product, `import SwiftUIRegistryDesignSurface`, apply `designSurface()` inside `registryTheme(_:)`. A debug build gains a draggable Tune button. A floating, movable, resizable panel opens in the tool's own window. The window covers the whole app, live underneath on every tab, sheet, and cover. A release build returns the content unchanged. Tokens persist as `registry-tokens.json` in the app's Documents directory. Export them as a preset code any registry tool applies, or as Swift to paste.
- Tap to select. Select arms the next tap; the panel scopes to the tokens reaching the tapped item. Every tagged item on screen is outlined with its name and listed under On this screen. `ItemSelection.chain` names every item under the pick, innermost first. A host can offer the row around a button too. A pick on nothing clears the selection.
- Host tokens. Conform the app's token value to `TokenDocument`: a shipped value, a file name, pages of `.number`, `.choice`, and `.color` knobs, and `apply()`. Pass it to `designSurface(tokens:)`. The panel gains an App tokens section that writes back to the app.
- Per item knobs. Register numeric knobs with `designSurface(knobs:)` and `ItemKnob`; read one with `registryKnob(_:_:default:)`. They persist beside the tokens in `design-knobs.json`; only a moved value is written.
- The host hooks overload `designSurface(enabled:tunesRegistryTheme:knobs:itemTitle:page:panelEnvironment:panel:)`, for an app that paints registry items from its own tokens. It compiles in every configuration.

  | Parameter | Effect |
  | --- | --- |
  | `enabled` | the app's own switch |
  | `tunesRegistryTheme: false` | drops the panel's theme sections |
  | `panel` | adds the app's sections |
  | `page` | pushes the app's page for a picked item |
  | `panelEnvironment` | wraps the panel's stack |
  | `itemTitle` | names rows and outlines |

- Foundations gained `registryItem(_:)` and `registryScreen(_:)`, the tags the surface selects and names screens by. It also gained the surface reporter and per item knobs in the environment. All are inert without a surface.
- A fourth generator, `swiftui-registry generate item-tokens`, writes the item to token map that scopes the panel. CI checks it for drift with the other outputs.
- `CHANGELOG.md`, a repository layout table in `CONTRIBUTING.md`, and `docs/RELEASE-CHECKLIST.md`, the list a release closes line by line.

### Changed

- The tuning panel moved from the Showcase into the product, which the Showcase now consumes. It is a floating card in the tool's own window, not a sheet or inspector column. A drag bar moves it, a corner grip resizes it, a chevron collapses it. It can hang off the leading, trailing, and bottom edges; its grab strip stays inside the safe area, and it never goes above the top. On iPad, a drag against the trailing edge snaps it into a full height column. Its frame is remembered per size class and re clamped on rotation.
- The tool's chrome uses fixed system values, never the tuned theme: Tune button, card, selection ring, outlines, guides. Its motion is off under Reduce Motion.
- Every installable item declares the `0.3.0` foundations floor, because every one applies `registryItem(_:)`. The installer prints `from 0.3.0 up to the next minor version`.
- `swift-sharing` is pinned to 2.9.x (from `2.9.1`, below `2.10.0`) with no traits. A consumer that already resolves `xctest-dynamic-overlay` is not forced onto a newer major.
- Planning, research, and run logs left the repository. It holds only what an adopter needs.

### Fixed

- The tool no longer advertises an older Homebrew tag as an update; the notice needs a tag newer than the running tool.
- A tap on a List row under the card pushes again. The key window follows the text field that takes focus: a field in the app takes the keyboard, a field in the panel takes it back. Before, the key window switched during hit testing, which cancelled the touch.
- The collapse control has its own accessibility frame; the drag runs over the whole bar as a simultaneous gesture.
- The card is clamped into the window's safe area. Its strip neither sits under the status bar nor stops short of it.
- Edge cases:

  | Case | Behavior |
  | --- | --- |
  | non positive step, or shipped value outside its range | knob stays usable, logged |
  | token file that fails to decode (hand edited, newer version) | shipped values stay, logged once, not rewritten until a knob moves |
  | choice knob whose options no longer list its value | value kept |
  | empty item or screen name | tags nothing |
  | empty host title | falls back to the item's name |
  | equal frames | ties resolve by name |
  | item scrolled off the screen | not listed as on it |

- Foundations compiles on macOS again after `Color(uiColor:)` crept into the selection ring. An unused anchor preference left the public API before it shipped.

### Known limitations

- Two visual references, `auth-light` and `nutrition-light`, are stale after the tuning strip change: 2.70 and 1.54 percent against the 1.5 percent tolerance. Both are recaptured and await the owner's copy into `ReferenceImages/`. Until then those two Showcase UI tests fail (`docs/visual-testing.md`).
- The iPad simulator sometimes never reports idle after keyboard input. The UI suite passes `-disable-animations` on that destination. One test records a measured skip instead of a failure (`docs/visual-testing.md`).
- The tool's window installs over the first connected scene. A second window of the same app on iPad is not covered.
- Items installed from `0.1.0` or `0.2.0` carry no `registryItem(_:)` tag. Select and the outlines find nothing in them until `swiftui-registry install <item> --update`.
- The Showcase is portrait only on iPhone. Card rotation runs on the iPad destination and in the host apps.

## 0.2.0 (2026-09-07)

The Stage 7 release. The same `brew install mangobyte-dev/tap/swiftui-registry` or `brew upgrade swiftui-registry` applies.

### Added

- 16 items, growing the catalog from 57 to 73:
    - 6 chat and feedback components: `attachment`, `bubble`, `marker`, `message`, `message-scroller`, `toast`.
    - 7 recipes: `carousel`, `chart-tooltip`, `date-picker`, `input-otp`, `menubar`, `sheet`, `typography`.
    - 3 blocks: `dashboard`, `signup-form`, `questionnaire`.
- `describe <item>` prints metadata, usage snippet, accessibility contract, install order, package requirement, and files, with `--source` and `--format json`. `info --destination <dir>` reports every owned file as up to date, modified, or missing through the receipt.
- Preset code format version `b`. It appends to the version `a` fields and the custom accent block. The new fields: font design, a surface step that drives a four level elevation ladder, a chart palette. Optional light and dark pairs cover background, foreground, and secondary foreground. A code stays `a` while nothing appended leaves its default. Every existing code still decodes to the same theme.
- The `SwiftUIRegistryFoundations` 0.2.0 API, all defaulted so existing initializers compile:
    - `fontDesign`, `surfaceOpacity`, `surfaceStep`, `chartPalette`, `background`, `foreground`, `secondaryForeground` on `RegistryTheme`.
    - The `mango` preset, the sample design system (`docs/mango.md`).
    - `RegistrySurfaceLevel` with `registrySurface(level:)`.
- Three agent skills under `Skills/` (consuming, theming, authoring), mirrored to `~/.claude/skills/`.
- iPad Pro 13 inch captures of every item, light and dark; the website shows both idioms.

### Changed

- `button`, `checkbox`, `accordion`, and `breadcrumb` keep the iPadOS pointer effect. The sidebar recipe adds the `sidebarAdaptable` tab view.
- `chart` reads the chart palette and declares the 0.2.0 foundations floor. Every other item kept 0.1.0 at this release.

## 0.1.0 (2026-09-06)

The first published contract.

### Added

- 57 source owned items (31 components, 8 blocks, 18 recipes), the `SwiftUIRegistryFoundations` theme package, and the `swiftui-registry` tool.
- The tool installs items with receipt backed three way updates. It searches and validates the catalog, reads and writes preset codes, and serves every operation over MCP. It generates the catalog, the Showcase manifest, and the website data. Outside a clone it fetches this tag's registry snapshot on first use.
- The release workflow attaches `swiftui-registry-macos-universal.tar.gz` (arm64 and x86_64) plus its `.sha256` for the Homebrew tap.
- The `TodoCounter` example, a second consumer on the Composable Architecture.
