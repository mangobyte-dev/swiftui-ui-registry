---
name: swiftui-registry-theming
description: Theme a SwiftUI app on the registry with RegistryTheme, the seven presets, preset codes, the MANGO sample design system, and the Create studio, using the swiftui-registry preset commands.
metadata:
  short-description: Presets, preset codes, MANGO, and the Create studio.
---

# SwiftUI Registry theming

## Goal

Give an app one coherent brand without a theme engine: a `RegistryTheme` set
once at the scene root, a short preset code that survives copy and paste, and a
worked design system (MANGO) to extend.

This skill answers two of the recorded iOS design-system pain points
(`docs/component-roadmap.md`, D8; `docs/mango.md`, Goal):

- Drift, the same primitives rebuilt with different padding, radii, and color
  every sprint: one `RegistryTheme` applied once with `registryTheme(_:)`, its
  tokens read from the environment rather than from scattered constants and never
  as `Color` statics that type-check into nonsense (`docs/architecture.md`,
  Foundations; `docs/mango.md`, Goal, the `Color`-extension trap).
- Sameness, every app converging on one skin: the preset code plus the Create
  studio and MANGO as the worked brand let a team build a distinct look on the
  same items (`docs/mango.md`, Goal; `docs/component-roadmap.md`, D8).

## Quick start

1. Apply a preset at your scene root:

   ```swift
   ContentView()
       .registryTheme(.graphite)
   ```

2. Read a code's tokens, Swift, and website URL: `swiftui-registry preset decode a13GkaOXWwIF`.
3. Write a code into an app as a theme file: `swiftui-registry preset apply a13GkaOXWwIF --destination path/to/YourApp`.
4. Apply the written theme: `ContentView().registryTheme(.app)`.
5. Read an edited theme file back into a code: `swiftui-registry preset resolve path/to/YourApp/RegistryTheme+App.swift`.

## API interface

- Theme, metrics, presets, and root modifiers: `references/foundations-interface.md` (a pointer to the shared `SwiftUIRegistryFoundations.swiftinterface`)
- The preset code layout, versions `a` and `b`: `references/preset-format.md`
- The MANGO design system and its build-your-own steps: `references/mango.md` (a pointer to `docs/mango.md`)

Quote every theme API and every code from these, never from memory: a code is
produced by the codec, never typed by hand (`docs/mango.md`, The MANGO preset
code).

## How to apply a theme once at the root

The why: `RegistryTheme` is the set-up-once contract; applied once, every
registry item below inherits the same accent, surfaces, borders, and metrics, and
Apple controls follow the accent through the tint (`docs/architecture.md`,
Foundations).

1. Pick one of the seven presets (`system`, `graphite`, `indigo`, `rose`,
   `emerald`, `amber`, `mango`) and apply it at the scene root:

   ```swift
   ContentView()
       .registryTheme(.mango)
   ```

2. `.system` inherits the app tint already in place; the others declare an accent
   and tint the subtree.

- **DO** apply the theme once, before the scene appears; the tokens flow through
  the environment to every item below.
- **DO NOT** switch a theme's accent between `nil` and a value at runtime:
  `tint(nil)` resets the tint rather than inheriting it, so the subtree is
  replaced and the state below it resets. Keep the accent's presence stable, or
  pass `Color.accentColor` instead of `nil` (`docs/architecture.md`, Foundations).
- **DO NOT** define tokens as `Color` statics; they live on the theme value in
  the environment (`docs/mango.md`, Goal, the `Color`-extension trap).

## How to pick a preset and read its code

The why: a preset code is a `RegistryTheme` as one short shareable string that
the tool, the Showcase, the website, and the MCP server all read and write
(`docs/registry-spec.md`, Preset codes).

1. Decode a code to its knobs, the Swift, and the website URL:

   ```sh
   swiftui-registry preset decode a13GkaOXWwIF
   ```

   ```text
   Preset
     code                      a13GkaOXWwIF
     version                   a
     accent                    indigo
     ...
     url                       https://swiftui-registry.mangobytekw.workers.dev/create?preset=a13GkaOXWwIF
   ```

2. Add `--json` for the machine-readable knobs, the same payload the MCP
   `describe_preset` tool returns.
3. Get just the website URL with `swiftui-registry preset url a13GkaOXWwIF`.

- **DO** treat the code as the portable form; `a13GkaOXWwIF` is the Indigo preset
  on the foundation metrics (`docs/registry-spec.md`, Preset codes).
- **DO NOT** reorder or hand-assemble a code's characters; decode it and read the
  fields.

## How to write a code into an app

The why: `preset apply` turns a code into `RegistryTheme+App.swift`, an extension
declaring `RegistryTheme.app` for the consumer to apply once at the scene root;
the theme file is not a registry item and carries no receipt (`docs/registry-spec.md`,
Preset codes).

1. Write the file:

   ```sh
   swiftui-registry preset apply a74hGF01CVunaG0vzZJG --destination path/to/YourApp
   ```

   It writes `RegistryTheme+App.swift` with a header naming the code and URL:

   ```swift
   import SwiftUI
   import SwiftUIRegistryFoundations
   import UIKit

   // swiftui-registry preset a74hGF01CVunaG0vzZJG
   // https://swiftui-registry.mangobytekw.workers.dev/create?preset=a74hGF01CVunaG0vzZJG
   // Written by `swiftui-registry preset apply`. Edit freely; `swiftui-registry preset resolve` reads it back into a code.

   extension RegistryTheme {
       /// Apply once at the scene root: `ContentView().registryTheme(.app)`.
       static let app = RegistryTheme(
   ```

2. Apply it at the root: `ContentView().registryTheme(.app)`.
3. Edit the initializer in place; it is your source now.
4. Read your edited file back into a shareable code:

   ```sh
   swiftui-registry preset resolve path/to/YourApp/RegistryTheme+App.swift
   ```

- **DO** edit the theme freely after applying; `resolve` parses the initializer,
  never trusting the file header.
- **DO** pass `--force` to `preset apply` to replace an edited file; without it,
  apply replaces the file only while it still resolves to the code in its header.
- **DO NOT** commit a code typed by hand into the header and expect `resolve` to
  trust it; the initializer is the source of truth.

## How to build a brand the MANGO way

The why: naming the layers before the surface is the point of the Layers order,
because the most neglected layer is the conceptual model (`docs/mango.md`,
Conceptual model). MANGO is the template a team follows for its own brand.

1. Work the Layers order from `docs/mango.md`: the Domain (who the brand serves),
   then the Conceptual model (the five things a design system here is made of:
   the theme value, the environment, the presets, the code, the owned copies),
   then the Surface (tokens, typography, motion).
2. Set the tokens as a `RegistryTheme` (MANGO's are in `docs/mango.md`, Surface,
   Tokens: a custom mango accent with a light and dark pair, `onAccent: .black`,
   `surface: .primary.opacity(0.07)`, `border: .primary.opacity(0)`, radii 10, 14,
   24, spacing 8, 16, 28, control padding 16, disabled 0.4).
3. Apply the typography once at the MANGO scene root with `.fontDesign(.rounded)`,
   and put `.monospacedDigit()` on every value that can change so digits do not
   shift width.
4. Adopt the motion vocabulary: a critically damped `.spring(response: 0.4,
   dampingFraction: 1.0)` by default, `dampingFraction: 0.8` only after a gesture
   that carried momentum, press feedback (scale 0.97 on `isPressed`, applied on
   press), and an `.opacity` cross-fade under `accessibilityReduceMotion`
   (`docs/mango.md`, Surface, Motion).
5. Read the code back with `preset resolve`; MANGO's is `a74hGF01CVunaG0vzZJG`,
   pinned in `Registry/preset_vectors.json`.

- **DO** keep a customized item as an owned copy tracked by the receipt, with a
  header comment naming the item and version it came from and every edit, as
  MANGO does with `MangoButtonStyle` and `MangoMetricCard` (`docs/mango.md`, What
  MANGO customized in the Showcase).
- **DO NOT** add a `theme` item kind; a preset code already round-trips through
  the tool, the Showcase, the website, and the MCP server, and the theme file is
  by contract not a registry item (`docs/component-roadmap.md`, slice 6 decision).

## How to use the Create studio and the tuning panel

The why: the Create studio and the Showcase's tuning panel are the theme creator;
the panel stays beside the catalog so a slider move shows on whichever demo is
open (`docs/architecture.md`, Foundations).

1. Open the Create page at the code's URL to see the tokens as a CSS board and,
   for one of the presets, the real capture: `?preset=<code>` on the website (for
   example `https://swiftui-registry.mangobytekw.workers.dev/create?preset=a13GkaOXWwIF`,
   from `preset url` or `preset decode`).
2. In the Showcase's Tune tab, move the sliders, then use the export actions:
   Copy Swift for the exact `RegistryTheme(...)` initializer to paste at a root,
   Copy Code for the theme as a preset code, and Import to load either back into
   the knobs (`docs/architecture.md`, Foundations).
3. Export a MANGO-style theme package from the Create studio's Export tab:
   `RegistryTheme+App.swift` and `THEME.md`, with copy buttons and no downloads
   (`docs/component-roadmap.md`, slice 7).

- **DO** use Copy Swift when you want the initializer to paste, and Copy Code when
  you want the portable string.
- **DO NOT** expect the Create page to render SwiftUI; it shows the CSS token
  board and, only for the six built-in presets, the real capture, and never
  claims otherwise (`docs/architecture.md`, Foundations).

## How to use the version b fields

`Registry/preset_vectors.json` declares `version: "b"` with `maxLength: 48`, so
the Create studio's fields are live. Version `b` appends fields after the version
`a` block, and every `a` code still decodes (`docs/registry-spec.md`, Preset
codes, "Format, version `b`").

1. Decode a `b` code; it carries the appended keys:

   ```sh
   swiftui-registry preset decode b3nbXHeB3DzH
   ```

   ```text
     version                   b
     ...
     fontDesign                rounded
     surfaceStep               0.02
     chartPalette              accent
     background                none
     foreground                none
     secondaryForeground       none
   ```

2. The appended fields, in order: `fontDesign` (default, rounded, serif,
   monospaced), `surfaceStep` (the elevation ladder's step), `chartPalette`
   (accent, spectrum, monochrome), then optional light and dark pairs for
   `background`, `foreground`, and `secondaryForeground`.

- **DO** expect a tuning that leaves every `b` field at its default to encode to
  its `a` code; a code is `b` only when an appended field leaves its default or a
  pair is present.
- **DO NOT** carry a custom font family in a code; it lives only in the Swift
  export and the theme package (`docs/registry-spec.md`, Preset codes).
