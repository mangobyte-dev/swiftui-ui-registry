# Registry specification version 1

The canonical schema is `Registry/schema.json`. JSON is used because it is inspectable, widely supported, and does not require a Swift tool to discover an item

## Registry index

`Registry/registry.json` contains:

- `schemaVersion`: currently `1`
- `name`: registry name
- `items`: relative paths to item documents

## Item fields

- `schemaVersion`: schema compatibility number
- `version`: semantic item version recorded as provenance
- `name`: deterministic kebab-case installation name
- `kind`: `component`, `block`, `flow`, or `recipe`
- `description`: one sentence describing product purpose
- `usage`: a minimal compiling SwiftUI snippet showing the item's public API at a call site; schema version 1 declares it as an additive optional field, but this catalog requires it non-empty for every item. Installable items quote the API declared in their canonical source; recipes carry the native snippet from their `docs`
- `docs`: optional markdown guidance; required and non-empty for `recipe` items
- `files`: canonical source path and consumer target filename; empty for `recipe` items
- `registryDependencies`: other item names resolved before this item
- `packageDependencies`: Swift package, product, and version requirement the consumer must provide; entries may add the package `sourceURL` and must pair any version requirement with a machine-resolvable `swiftPM` rule
- `platforms`: declared Apple platform and minimum version
- `tags`: discovery terms, not API behavior
- `aliases`: optional kebab-case words people searched for and did not find (`dropdown`, `modal`, `loading`); search ranks an alias hit between a name hit and a tag hit. Add an alias from an observed miss, not from a thesaurus
- `accessibility`: concrete behavior and known requirements
- `preview`: for an installable item, the source file, the Xcode preview name, and optional screenshot paths, all required except the screenshots; a `recipe` may carry a `preview` with `screenshots` only, never a source or name, because it has no source of its own

## Item value gate

An installable `component` or `block` must add a meaningful reusable treatment or composition beyond a native API. Guidance whose entire value is a native modifier choice, such as a one-line alias of a native style or a preview-only usage example, ships as a `recipe`

A `recipe` is native guidance, not installable source. It declares `files: []`, carries its guidance in `docs`, and keeps discovery, platform, and accessibility metadata. Resolving or installing a recipe fails loudly: the installer prints the recipe's `docs` and exits with code 2. Installable items must not declare a `registryDependency` on a recipe

## Resolution

Resolution is depth first and deterministic in dependency declaration order. Each item is installed once. Unknown items, dependency cycles, missing source, duplicate targets, unsafe paths, untracked collisions, and modified receipt-backed targets fail loudly

## Validation

`Sources/RegistryKit/Validation.swift` is the single structural validator for the catalog. It checks every item against the canonical schema constraints (required keys, types, enums, undeclared keys, and the recipe conditional rules), registry index completeness in both directions, declared source and preview file existence, dependency closure resolution (unknown items, cycles, and recipes as dependencies), numeric platform floor format, package dependency shape, the non-empty `usage` snippet every item must carry, and the design surface's root tag: an installable item that depends on `SwiftUIRegistryFoundations` applies `.registryItem("<name>")` in its first source file, since the surface selects items by that tag and a new item that forgot it would be invisible to Select

Every consumer runs the same validator: the installer validates the full registry before resolving anything, search, the MCP server, and the generators load items through that validated path, `swiftui-registry validate` runs the checks standalone and exits 0 or 1 with a readable report (optionally scoped to named items and their dependency closures), and `Tests/RegistryKitTests/ValidationTests.swift` proves each defect class is rejected with the ordered issues captured in `Fixtures/validation-cases.json`. A structural rule that is not in this validator is not enforced

## Generated catalog

`docs/catalog/` is a build product of `swiftui-registry generate catalog`, which loads the registry through the validated path and writes one deterministic page per item plus an index grouped by kind. Each page leads with what a consumer sees and copies: description, the lead screenshot with links to any alternates, one install command followed by its package requirement (or, on a recipe, the line "Nothing to install. Copy the snippet below" and no Install heading at all), then the `usage` snippet, and on a recipe the "Why native is enough" guidance from `docs`. Everything else recedes into a closing Details list: kind, version, platforms, registry dependencies or install order, the accessibility contract, and the source link carrying its Xcode preview name. Output carries no timestamps, so regeneration is byte-stable; `Tests/RegistryKitTests/GeneratorTests.swift` regenerates into an in-memory destination and asserts byte equality, which means the catalog can never drift from metadata. Never edit `docs/catalog/` by hand; edit the item document and regenerate

## Generated website data and Showcase manifest

`Sources/SwiftUIRegistryDesignSurface/RegistryItemTokens.swift` is a build product of `swiftui-registry generate item-tokens`: for every component and block, the sorted set of `RegistryTheme` fields and `RegistryMetrics` fields its sources and its dependency closure read (`theme.<field>` and `theme.metrics.<field>` references, plus the fields the foundations `registrySurface(level:)` and `surface(at:)` calls read). The design surface scopes its panel to that set when an item is selected; the file is never edited by hand

`Website/content/registry.json` (with the captures copied to `Website/public/images/`) is a build product of `swiftui-registry generate site-data`, and `RegistryCatalogManifest.swift` plus the UI suite's `RegistryItemNames.swift` are a build product of `swiftui-registry generate showcase-manifest`. Both load the registry through the validated path, both are deterministic, and `Tests/RegistryKitTests/GeneratorTests.swift` asserts byte equality with the checked-in files. The Next.js site under `Website/` reads only that JSON; a page leads with the captured preview, then one install command, then the `usage` snippet, and keeps the full source and the accessibility contract on the same page. Screenshots referenced by `preview.screenshots` are produced by `python3 Scripts/capture_previews.py`

## File ownership

A target path is relative to the destination selected by the consumer. Version 1 does not prescribe groups, targets, module names, or project-file mutation

After copying, the consumer owns the target file. The registry remains the provenance source, not a remote authority over local edits

The installer stores provenance under `.swiftui-registry/` in the selected destination. `receipt.json` records item versions, registry and package dependency declarations (including each declared `swiftPM` rule at install time), content digests, targets, and base snapshot paths. Base and conflict artifacts use non-Swift extensions so they cannot become duplicate declarations in a buildable source folder

## Package dependencies

The prototype reports package dependencies through metadata but does not install them. This avoids unsafe `.xcodeproj` mutation and keeps dependency approval with the consuming team

A dependency entry is actionable, not only prose. `sourceURL` names the package location and `swiftPM` states the resolvable requirement: `kind` is one of `upToNextMinor`, `upToNextMajor`, `exactVersion`, or `range`, with a semantic `minimumVersion` and, for `range` only, an exclusive `maximumVersionExclusive`. The validator rejects a version requirement that lacks a `swiftPM` rule. The installer prints the resulting instruction (package URL, requirement, and product) with every install and records the declared entries in the receipt

## Compatibility policy

Pre-1.0 foundations evolve by minor version: within `0.minor.patch`, a patch release stays source compatible and a minor release may change the contract, so items pin `upToNextMinor` from their known-good floor. Copied source is verified against its declared platform floor and the recorded foundation range. The receipt records what each item required at install time, so a consumer can audit an installation against a later registry state

`SwiftUIRegistryFoundations` 0.1.0 is the initial published contract. The `0.1.0` tag was created on 2026-09-05 at the commit that introduced the accent and onAccent tokens; it resolves for consumers once pushed

## Evolution rules

- Additive optional fields may be introduced within schema version 1
- Removing or changing field meaning requires a new schema version
- Item API evolution does not silently overwrite copied code
- Receipts identify exact source and installed content, not only an item name
- Updating a modified file requires a clean three-way merge or explicit conflict review

## Preset codes

A preset code is a `RegistryTheme` as a short shareable string, the registry's counterpart of shadcn's `--preset` codes: `a13GkaOXWwIF` is the Indigo preset on the foundation metrics. The reference implementation is RegistryKit's `Preset.swift` behind `swiftui-registry preset`; `Website/lib/preset.ts` (the Create page) and the Showcase's `ThemePreset.swift` (the tuning panel's Copy Code and Import, the `-preset <code>` launch argument) reproduce it, and `Registry/preset_vectors.json` pins codes all three must agree on byte for byte (`Tests/RegistryKitTests/PresetTests.swift` and `PresetContractTests.swift` check RegistryKit and, through Node, the TypeScript; the Showcase package's `ThemePresetTests` checks the Showcase)

Format, version `a`: the knobs pack little-endian into one integer written in base62 (`0-9A-Za-z`) behind the version letter. Fields, in order, with their bit widths: `accent` (4 bits; system, ink, blue, indigo, purple, pink, red, orange, yellow, green, mint, teal, cyan, brown, custom), `darkLabelOnAccent` (1), `surfaceOpacity` (6; 0 to 0.2 by 0.005), `borderOpacity` (5; 0 to 0.3 by 0.01), `borderWidth` (3; 0.5 to 3 by 0.5), `emphasizedBorderWidth` (3; 1 to 4 by 0.5), `compactRadius` (4; 0 to 12), `controlRadius` (5; 0 to 22), `cardRadius` (6; 0 to 32), `compactSpacing` (4; 4 to 16), `standardSpacing` (5; 8 to 32), `sectionSpacing` (6; 12 to 48), `controlHorizontalPadding` (5; 8 to 24), `disabledOpacity` (4; 0.2 to 0.8 by 0.05), 61 bits in all. A numeric field stores its index on that grid, the tuning panel's slider grid, so a value off the grid snaps to it on encode. A custom accent appends 24 bits of RGB, one flag bit, and 24 more bits for a separate dark accent when the flag is set. `positive`, `negative`, and the environment switches are never part of a code

Rules, binding on every implementation: never reorder or resize an existing field, only append with the default at index 0; new fields go after the custom accent block; a field index beyond its value count makes the code invalid rather than clamping; bits above the known fields are ignored so an older decoder tolerates a newer code; a version `a` code has at most 22 characters. A change to any of these is a new version letter

Format, version `b`: the Create studio (decision D4, `docs/component-roadmap.md`) appends its fields after the version `a` block, so every `a` code still decodes and a tuning that leaves every `b` field at its default still encodes to its `a` code. The letter `b` precedes the same base62 packing, now read as an arbitrary-width little-endian integer because a fully populated `b` code exceeds 128 bits. After the `a` layout and its custom accent block come, in order: `fontDesign` (2 bits; default, rounded, serif, monospaced), `surfaceStep` (3 bits, an index into the value list 0.02, 0.00, 0.01, 0.03, 0.04, 0.05, 0.06, 0.07, so the default 0.02 is at index 0 as the append rule requires), `chartPalette` (2 bits; accent, spectrum, monochrome, with index 3 reserved and rejected), then three optional color pairs in the order `background`, `foreground`, `secondaryForeground`, each one flag bit followed, when set, by 24 bits of light RGB, a dark flag, and 24 more bits of dark RGB when that dark flag is set. A decoded `b` tuning carries the keys `fontDesign` (string), `surfaceStep` (number), `chartPalette` (string), and `background`, `backgroundDark`, `foreground`, `foregroundDark`, `secondaryForeground`, `secondaryForegroundDark` (each `#RRGGBB` or null, the dark one null unless set); a decoded `a` tuning carries none of them and takes those defaults implicitly. A `b` code has at most 48 characters. A custom font family is never in a code: it lives only in the Swift export and the theme package

`swiftui-registry preset apply <code> --destination <path>` writes `RegistryTheme+App.swift`, an extension declaring `RegistryTheme.app` for the consumer to apply once at the scene root; it replaces an existing file only while that file still resolves to the code in its own header, and `--force` overrides. `resolve <path>` parses the initializer back into a code (never trusting the header), `decode <code>` prints the knobs, the Swift, and the website URL, and the MCP server exposes the same as `describe_preset` and `apply_preset`. The theme file is not a registry item: it carries no receipt entry and the installer never touches it

The design tokens file: `SwiftUIRegistryDesignSurface`, an optional package product, keeps a tuning as `design-tokens.json` in the app's Documents directory through `@Shared(.designTokens)` (swift-sharing's file storage), and that file is the surface's export. `code` and `version` name the same knobs as a preset code; `tuning` holds the keys `preset decode --json` prints under `tuning`, every key always present and colors spelled `#RRGGBB`; `environment` holds the appearance, text size, and direction switches a code never carries. Reading is forgiving in one direction: a `tuning` object may name any subset of its keys over the defaults, and a document with only a `code` loads that code, so an agent pushes a theme onto a simulator by writing either, while a wrong code, color, or accent is refused rather than guessed (`ThemeTuning+File.swift`, checked by the Showcase package's `DesignTokensFileTests`). The `code` is what an agent feeds to `preset apply` or `apply_preset`; the file is not a registry item and the installer never touches it

## Agent usage

The tool finds the registry in a fixed order: `--registry <path>`, then a clone enclosing the working directory, then a cached snapshot of the pinned release fetched from the published tag on first use (`docs/cli-migration.md`, Resolution and distribution). An agent should:

1. Search item metadata by name, kind, tags, platform, and minimum version with `swiftui-registry search`
2. Read the dependency closure and package requirements
3. Read the usage snippet, accessibility notes, dependency closure, package requirements, and canonical source with `swiftui-registry describe <item>`
4. Preview the installation with `swiftui-registry install <item> --plan --destination <path>`, a read-only mode that prints the ordered closure, per-target statuses, package requirements, collisions, and manual integration steps, and writes nothing
5. Install the item sources
6. Compose through the public initializer rather than rewriting the item from memory
7. Compile the consumer at its deployment floor
8. Before `--update`, audit owned source against the canonical registry with `swiftui-registry install <item> --diff --destination <path>`, which requires the installation receipt and exits 0 on parity or 1 with unified diffs

The same steps are available as MCP tools from `swiftui-registry mcp` (`search_items`, `describe_item`, `plan_install`, `diff_item`, `install_item`, plus `describe_preset` and `apply_preset` for preset codes) over the stdio transport; `Tests/RegistryKitTests/MCPTests.swift` pins the wire shape as inline snapshots and `MCPContractTests.swift` drives the real registry
