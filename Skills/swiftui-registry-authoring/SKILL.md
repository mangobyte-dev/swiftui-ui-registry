---
name: swiftui-registry-authoring
description: Add an item to the SwiftUI registry under AGENTS.md's rules: decide the kind against the value gate, write the source and the item JSON, then validate, install into the Showcase, capture, regenerate, and run the UI suite.
metadata:
  short-description: Author a registry item under the project's rules.
---

# SwiftUI Registry authoring

## Goal

Add a component, block, or recipe to the registry so it stays part of one
coherent, maintainable catalog. This skill teaches the conceptual model (item,
kind, dependency, receipt, code) before the surface, because naming those first
is what keeps an addition consistent (`docs/component-roadmap.md`, D6;
`docs/mango.md`, Conceptual model).

It answers two of the recorded pain points (`docs/component-roadmap.md`, D8):

- Sameness and sprawl: the value gate and the two-consumer rule stop the catalog
  filling with redundant wrappers, so each item earns its place (`docs/registry-spec.md`,
  Item value gate; `docs/philosophy.md`, "Evidence before extraction").
- Maintenance risk: one structural validator, receipts, byte-exact generated
  outputs, and `--diff`/`--update` keep an item auditable as the registry evolves
  (`docs/architecture.md`, Installation behavior and Update policy).

Read `AGENTS.md` in full before authoring; it is the contract this skill serves.

## Quick start

1. Decide the kind against the value gate (see below).
2. Write the canonical source under `Registry/sources/components/` or
   `Registry/sources/blocks/` (a recipe has no source).
3. Write the item document under `Registry/items/` and add it to
   `Registry/registry.json`.
4. Run the verification list, cheapest first: `references/checklist.md`.

## API interface

- The item schema, every field with types and constraints: `references/item-schema.md`
- The authoring rules and their why: `references/agents.md` (a pointer to `AGENTS.md`, `docs/philosophy.md`, `docs/architecture.md`)
- The scoped verification list as a checklist: `references/checklist.md`

Quote every public API in a `usage` snippet from the item's real canonical source,
never from memory (`AGENTS.md`, Rules; `docs/component-roadmap.md`, D6).

## How to decide the kind

The why: an installable item must add a meaningful reusable treatment or
composition beyond a native API; guidance whose whole value is a native modifier
choice ships as a recipe (`docs/registry-spec.md`, Item value gate).

1. Choose `component` when iOS has no native control for the need, or the
   treatment is reusable across items (a style, a focused modifier, or a small
   composition).
2. Choose `block` when it composes registry items into an architecture-neutral,
   screen-sized composition a consumer installs whole.
3. Choose `recipe` when a one-line Apple API is the entire treatment; it installs
   nothing (`files: []`), carries its guidance in `docs`, and exits with code 2
   if someone tries to install it.

- **DO** ship a wrapper that merely renames an Apple control as a recipe, not a
  component (`README.md`, Taxonomy).
- **DO NOT** let an installable item declare a `registryDependency` on a recipe;
  recipes are guidance, not source (`docs/registry-spec.md`, Item value gate).

## How to write the source

The why: keep raw SwiftUI controls visible at the call site and standardize their
appearance through SwiftUI style protocols and focused modifiers, so the item is
native-first (`docs/philosophy.md`, Native first; `docs/architecture.md`, View
boundaries).

1. Place presentation by the rule: the initializer carries what the view is
   (content, bindings, actions, required accessibility input); a presentation
   choice the view owns is a `registry`-prefixed copy-and-return method applied
   before generic modifiers (`InlineAlert(...) { }.registryVariant(.positive)`).
   Native controls keep presentation in a `registry` style, text treatments in a
   `registry` modifier with a variant argument, the theme in the environment, and
   sizes through Apple's `controlSize` (`AGENTS.md`, Rules; `docs/architecture.md`,
   View boundaries).
2. Read design values from the theme in the environment; use a semantic token
   only after two real items need the same meaning, and keep a style source-owned
   until two items use the exact same treatment (`AGENTS.md`, Rules).
3. Keep controlled state with the caller through bindings; own transient `@State`
   only when the interaction is self-contained (`docs/philosophy.md`, Architecture
   neutral).
4. Require accessibility input the view cannot derive from visible content; do
   not make an icon-only control's label optional (`docs/philosophy.md`,
   Accessible and adaptive by default).
5. Preview every meaningful variant across its contexts: the default, dark
   appearance, an accessibility Dynamic Type size, and right-to-left layout
   (`AGENTS.md`, Rules; `docs/philosophy.md`, Accessible and adaptive by default).

- **DO** support Dynamic Type, color scheme, layout direction, enabled state, and
  flexible parent sizing rather than hardcoding one context.
- **DO NOT** import app architecture, networking, or persistence into registry
  source (`docs/architecture.md`, Dependency direction).
- **DO NOT** apply registry styles or `registrySurface` to toolbars, tab bars, or
  floating chrome, where the system supplies Liquid Glass; use `.buttonStyle(.glass)`
  or `.glassProminent` there (`docs/philosophy.md`, Liquid Glass boundaries).

## How to write the item JSON

The why: names, files, dependencies, platforms, accessibility, previews, and a
usage snippet must be explicit in machine-readable metadata (`docs/philosophy.md`,
Agent legible). Every field is in `references/item-schema.md`.

1. Fill the required keys: `schemaVersion` (1), `version`, `name` (kebab-case),
   `kind`, `description`, `files`, `registryDependencies`, `packageDependencies`,
   `platforms`, `tags`, `accessibility`.
2. Write a non-empty `usage` snippet quoting the item's real public API from its
   canonical source; a recipe reuses the native snippet from its `docs`
   (`AGENTS.md`, Rules; `docs/registry-spec.md`, Item fields).
3. Declare every dependency, including a preview-only one: if the preview uses
   another item, list it in `registryDependencies` (the verifier caught `item`
   missing `avatar`, which its preview uses).
4. Add a `preview` with the source file and the Xcode preview name for an
   installable item; a recipe may carry only `screenshots`.
5. Add the package requirement with an actionable `swiftPM` rule (a version
   requirement without a `swiftPM` rule is rejected), and add the item's path to
   `Registry/registry.json`.
6. Add `aliases` only from an observed search miss, not from a thesaurus
   (`docs/registry-spec.md`, Item fields).

- **DO** keep `docs` non-empty for a recipe and `files` empty; keep `files`
  non-empty and `preview` present for a component or block (the schema's `allOf`
  rule, `references/item-schema.md`).
- **DO NOT** add a structural check anywhere but `Sources/RegistryKit/Validation.swift`;
  a rule that is not in the single validator is not enforced (`AGENTS.md`, Rules).

## How to validate, install, capture, and regenerate

The why: everything downstream of metadata is derived, never hand-edited, and a
byte-exact freshness test rejects drift (`AGENTS.md`, Purpose and Rules). The
exact commands and scoping are in `references/checklist.md`.

1. Validate: `swift run swiftui-registry validate`.
2. Install into the Showcase's canonical destination so the app compiles the item:

   ```sh
   swift run swiftui-registry install <name> --destination Examples/Showcase/SwiftUIRegistryShowcasePackage/Sources/SwiftUIRegistryShowcaseFeature/Installed
   ```

   Use `--force` only for an item whose owned copy the Showcase already tracks.
3. Register a demo for the item in `ItemDemos.swift` so the `-item <name>` launch
   renders it alone for capture (`AGENTS.md`, Boundaries).
4. Capture on the pinned simulator, then regenerate all three derived surfaces:

   ```sh
   python3 Scripts/capture_previews.py <name>
   swift run swiftui-registry generate catalog
   swift run swiftui-registry generate showcase-manifest
   swift run swiftui-registry generate site-data
   ```

5. Confirm no drift: `git diff --exit-code -- docs/catalog Examples/Showcase Website/content`, then `swift test` and `make format-check`.

- **DO** keep the Showcase's `Installed/` copies byte-identical to the registry
  source; MANGO's edited copies live under `Mango/` with renamed types instead
  (`docs/mango.md`, What MANGO customized in the Showcase).
- **DO** start the demo with the feature the item is named for selected, so the
  capture shows that feature (a verifier lesson).
- **DO NOT** hand-edit anything under `docs/catalog/`, `Website/content/`, or the
  Showcase manifest; regenerate it (`AGENTS.md`, Rules).

## How to run the UI suite on both destinations

The why: an item is publishable only when it installs, compiles at its declared
floor, and passes the demo walk's accessibility audit on both device classes
(`docs/philosophy.md`, Compile and visually verified; `docs/component-roadmap.md`,
Stage 7 exit criteria).

1. Build the Showcase, then run the UI suite on the iPhone 17, iOS 27 simulator
   (UDID `1807166B-C557-4F6B-B177-D5F3F701CBD7`, `AGENTS.md`, Environment pins):

   ```sh
   xcodebuildmcp simulator test --workspace-path Examples/Showcase/SwiftUIRegistryShowcase.xcworkspace --scheme SwiftUIRegistryShowcase --simulator-id 1807166B-C557-4F6B-B177-D5F3F701CBD7
   ```

2. Run it again on the iPad Pro 13-inch destination, set to en_US, with the pixel
   comparison gated to the iPhone idiom (`AGENTS.md`, Environment pins).

- **DO** run the suite after every visible change; it walks each demo and checks
  focus order, disabled states, validation copy, empty and placeholder states,
  RTL mirroring, accessibility-size typography, and approved visual references
  (`README.md`, Verify).
- **DO NOT** regenerate a visual reference merely to pass a test; follow
  `docs/visual-testing.md` (`AGENTS.md`, Rules).

## What the fresh-context verifier catches

These are the misses a fresh-context verifier repeatedly caught that an author
skips (project memory, Stage 7 slice orchestration):

1. A preview-only dependency left out of `registryDependencies` (the preview
   compiles in the Showcase but a clean consumer install fails).
2. A capture that does not show the feature the item is named for, because the
   demo did not start on that feature.
3. A scene-level snippet with no compile-only `Scene` in the demo file to prove
   it compiles.
4. A new item that does not update the counts and recipe-name set pinned in
   `Tests/RegistryKitTests/RegistryContractTests.swift`.

- **DO** re-read `AGENTS.md` and check the actual diff against it, item by item,
  before any done-claim; name any skipped step in the same sentence (`AGENTS.md`,
  Verification).
- **DO NOT** claim done while generated consumer sources differ from registry
  sources or any command in `references/checklist.md` failed.
