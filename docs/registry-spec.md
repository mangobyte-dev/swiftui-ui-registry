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
- `accessibility`: concrete behavior and known requirements
- `preview`: for an installable item, the source file, the Xcode preview name, and optional screenshot paths, all required except the screenshots; a `recipe` may carry a `preview` with `screenshots` only, never a source or name, because it has no source of its own

## Item value gate

An installable `component` or `block` must add a meaningful reusable treatment or composition beyond a native API. Guidance whose entire value is a native modifier choice, such as a one-line alias of a native style or a preview-only usage example, ships as a `recipe`

A `recipe` is native guidance, not installable source. It declares `files: []`, carries its guidance in `docs`, and keeps discovery, platform, and accessibility metadata. Resolving or installing a recipe fails loudly: the installer prints the recipe's `docs` and exits with code 2. Installable items must not declare a `registryDependency` on a recipe

## Resolution

Resolution is depth first and deterministic in dependency declaration order. Each item is installed once. Unknown items, dependency cycles, missing source, duplicate targets, unsafe paths, untracked collisions, and modified receipt-backed targets fail loudly

## Validation

`Scripts/registry_validation.py` is the single structural validator for the catalog. It checks every item against the canonical schema constraints (required keys, types, enums, undeclared keys, and the recipe conditional rules), registry index completeness in both directions, declared source and preview file existence, dependency closure resolution (unknown items, cycles, and recipes as dependencies), numeric platform floor format, package dependency shape, and the non-empty `usage` snippet every item must carry

Every consumer runs the same module: the installer validates the full registry before resolving anything, search loads items through that validated path, `python3 Scripts/validate.py` runs the checks standalone and exits 0 or 1 with a readable report (optionally scoped to named items and their dependency closures), and `Tests/RegistryTests/test_validation.py` proves each defect class is rejected. A structural rule that is not in this module is not enforced

## Generated catalog

`docs/catalog/` is a build product of `python3 Scripts/generate_catalog.py`, which loads the registry through the validated installer path and writes one deterministic page per item plus an index grouped by kind. Each page leads with what a consumer sees and copies: description, the lead screenshot with links to any alternates, one install command followed by its package requirement (or, on a recipe, the line "Nothing to install. Copy the snippet below" and no Install heading at all), then the `usage` snippet, and on a recipe the "Why native is enough" guidance from `docs`. Everything else recedes into a closing Details list: kind, version, platforms, registry dependencies or install order, the accessibility contract, and the source link carrying its Xcode preview name. Output carries no timestamps, so regeneration is byte-stable; `Tests/RegistryTests/test_catalog.py` regenerates into a temporary directory and asserts byte equality, which means the catalog can never drift from metadata. Never edit `docs/catalog/` by hand; edit the item document and regenerate

## Generated website data and Showcase manifest

`Website/content/registry.json` (with the captures copied to `Website/public/images/`) is a build product of `python3 Scripts/generate_site_data.py`, and `RegistryCatalogManifest.swift` plus the UI suite's `RegistryItemNames.swift` are a build product of `python3 Scripts/generate_showcase_manifest.py`. Both load the registry through the validated installer path, both are deterministic, and `Tests/RegistryTests/test_site_data.py` and `test_showcase_manifest.py` assert byte equality with the checked-in files. The Next.js site under `Website/` reads only that JSON; a page leads with the captured preview, then one install command, then the `usage` snippet, and keeps the full source and the accessibility contract on the same page. Screenshots referenced by `preview.screenshots` are produced by `python3 Scripts/capture_previews.py`

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

## Agent usage

An agent should:

1. Search item metadata by name, kind, tags, platform, and minimum version with `Scripts/search.py`
2. Read the dependency closure and package requirements
3. Inspect preview and accessibility notes
4. Preview the installation with `Scripts/install.py <item> --plan --destination <path>`, a read-only mode that prints the ordered closure, per-target statuses, package requirements, collisions, and manual integration steps, and writes nothing
5. Install the item sources
6. Compose through the public initializer rather than rewriting the item from memory
7. Compile the consumer at its deployment floor
8. Before `--update`, audit owned source against the canonical registry with `Scripts/install.py <item> --diff --destination <path>`, which requires the installation receipt and exits 0 on parity or 1 with unified diffs
