<!-- Reference for the swiftui-registry-theming skill. Quoted verbatim from the "Preset codes" section of docs/registry-spec.md (the data and installer contract). Do not hand-edit; the contract in docs/registry-spec.md governs, and this copy is refreshed when it changes. -->

# Preset code format

Quoted from `docs/registry-spec.md`, "Preset codes".

A preset code is a `RegistryTheme` as a short shareable string, the registry's counterpart of shadcn's `--preset` codes. For example, `a13GkaOXWwIF` is the Indigo preset on the foundation metrics. The reference implementation is RegistryKit's `Preset.swift` behind `swiftui-registry preset`. `Website/lib/preset.ts` (the Create page) and the Showcase's `ThemePreset.swift` (the tuning panel's Copy Code and Import, the `-preset <code>` launch argument) reproduce it. `Registry/preset_vectors.json` pins codes all three must agree on byte for byte. `Tests/RegistryKitTests/PresetTests.swift` and `PresetContractTests.swift` check RegistryKit and, through Node, the TypeScript; the Showcase package's `ThemePresetTests` checks the Showcase

Format, version `a`: the knobs pack little-endian into one integer written in base62 (`0-9A-Za-z`) behind the version letter. The fields, in order, with their bit widths, are:

- `accent` (4 bits; system, ink, blue, indigo, purple, pink, red, orange, yellow, green, mint, teal, cyan, brown, custom)
- `darkLabelOnAccent` (1)
- `surfaceOpacity` (6; 0 to 0.2 by 0.005)
- `borderOpacity` (5; 0 to 0.3 by 0.01)
- `borderWidth` (3; 0.5 to 3 by 0.5)
- `emphasizedBorderWidth` (3; 1 to 4 by 0.5)
- `compactRadius` (4; 0 to 12)
- `controlRadius` (5; 0 to 22)
- `cardRadius` (6; 0 to 32)
- `compactSpacing` (4; 4 to 16)
- `standardSpacing` (5; 8 to 32)
- `sectionSpacing` (6; 12 to 48)
- `controlHorizontalPadding` (5; 8 to 24)
- `disabledOpacity` (4; 0.2 to 0.8 by 0.05)

That is 61 bits in all. A numeric field stores its index on that grid, the tuning panel's slider grid, so a value off the grid snaps to it on encode. A custom accent appends 24 bits of RGB, one flag bit, and 24 more bits for a separate dark accent when the flag is set. `positive`, `negative`, and the environment switches are never part of a code

Rules, binding on every implementation:

- Never reorder or resize an existing field. Only append, with the default at index 0
- New fields go after the custom accent block
- A field index beyond its value count makes the code invalid; it does not clamp
- Bits above the known fields are ignored, so an older decoder tolerates a newer code
- A version `a` code has at most 22 characters

A change to any of these rules needs a new version letter

Format, version `b`: the Create studio appends its fields after the version `a` block. So every `a` code still decodes, and a tuning that leaves every `b` field at its default still encodes to its `a` code. The letter `b` precedes the same base62 packing, now read as an arbitrary-width little-endian integer, because a fully populated `b` code exceeds 128 bits

After the `a` layout and its custom accent block come, in order:

- `fontDesign` (2 bits; default, rounded, serif, monospaced)
- `surfaceStep` (3 bits, an index into the value list 0.02, 0.00, 0.01, 0.03, 0.04, 0.05, 0.06, 0.07, so the default 0.02 is at index 0, as the append rule requires)
- `chartPalette` (2 bits; accent, spectrum, monochrome, with index 3 reserved and rejected)
- three optional color pairs in the order `background`, `foreground`, `secondaryForeground`. Each pair is one flag bit. When the flag is set, 24 bits of light RGB follow, then a dark flag, then 24 more bits of dark RGB when that dark flag is set

A decoded `b` tuning carries these keys: `fontDesign` (string), `surfaceStep` (number), `chartPalette` (string), and `background`, `backgroundDark`, `foreground`, `foregroundDark`, `secondaryForeground`, `secondaryForegroundDark` (each `#RRGGBB` or null, the dark one null unless set). A decoded `a` tuning carries none of them and takes those defaults implicitly. A `b` code has at most 48 characters. A custom font family is never in a code: it lives only in the Swift export and the theme package

`swiftui-registry preset apply <code> --destination <path>` writes `RegistryTheme+App.swift`, an extension that declares `RegistryTheme.app` for the consumer to apply once at the scene root. It replaces an existing file only while that file still resolves to the code in its own header; `--force` overrides. `resolve <path>` parses the initializer back into a code and never trusts the header. `decode <code>` prints the knobs, the Swift, and the website URL. The MCP server exposes the same as `describe_preset` and `apply_preset`. The theme file is not a registry item: it carries no receipt entry, and the installer never touches it

The design tokens file: `SwiftUIRegistryDesignSurface`, an optional package product, keeps a tuning as `registry-tokens.json` in the app's Documents directory through `@Shared(.designTokens)` (swift-sharing's file storage). That file is the surface's export. `code` and `version` name the same knobs as a preset code. `tuning` holds the keys that `preset decode --json` prints under `tuning`, every key always present and colors spelled `#RRGGBB`. `environment` holds the appearance, text size, and direction switches that a code never carries

Reading is forgiving in one direction. A `tuning` object may name any subset of its keys over the defaults, and a document with only a `code` loads that code. So an agent pushes a theme onto a simulator by writing either one. A wrong code, color, or accent is refused, not guessed (`ThemeTuning+File.swift`, checked by the Showcase package's `DesignTokensFileTests`). The `code` is what an agent feeds to `preset apply` or `apply_preset`. The file is not a registry item, and the installer never touches it

Two files sit beside it since Stage 9:

- `design-knobs.json`: the per-item numeric knobs a host registers through `designSurface(knobs:)` and items read through `registryKnob(_:_:default:)`. It is keyed by item name, then knob name, and holds only values off their shipped defaults
- the host's own token document: a `TokenDocument` the app declares pages of knobs for, under the file name the document names. The surface applies it back to the app after every change
