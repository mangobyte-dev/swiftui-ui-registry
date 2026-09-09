# MANGO

MANGO is MangoByte's sample design system. It proves that a team can own a coherent brand on this registry without a theme engine. This document has two purposes. It records what MANGO is. It is also the template another team follows to build the same for their brand. The document uses the Layers of Product Design order: the domain, then the conceptual model, then the surface. This order settles the vocabulary before any surface choice. The conceptual model is almost always the most neglected layer

## Goal

Six pain points recur in iOS design-system work. MANGO shows the registry mechanism that answers each one:

- Drift: every sprint rebuilds the same primitives with different padding, radii, and color. One `RegistryTheme` answers this. Apply it once at the scene root with `registryTheme(_:)`. Its tokens read from the environment, not from scattered constants (docs/architecture.md, Foundations)
- Agent drift: three "add a settings screen" prompts produce three button styles. The item `usage` snippets, the `swiftui-registry mcp` server, and the skills answer this. They hand an agent what the app already decided (docs/registry-spec.md, Agent usage)
- No `MaterialTheme` equivalent: Apple ships the environment but not the set-up-once contract. `RegistryTheme` in the environment answers this, plus a preset code that survives copy and paste (docs/registry-spec.md, Preset codes)
- The `Color`-extension trap: tokens as `Color` statics type-check into nonsense like `Color.brand.secondary`. Tokens answer this by living on a theme value in the environment, never as `Color` statics (Sources/SwiftUIRegistryFoundations/RegistryTheme.swift)
- Unmaintained libraries: every SwiftUI design-system package is archived or asks for a maintainer. Source ownership with a receipt answers this. It uses a narrow foundations package pinned `upToNextMinor` from 0.3.0, and `--diff` and `--update` to audit later change (docs/architecture.md, Installation behavior and Update policy)
- Sameness: every app converges on one skin. The Create studio answers this, and MANGO itself as the worked brand built on the same items

## Domain

MANGO stands in for MangoByte's client work: banking-adjacent apps for a Kuwaiti audience, bilingual in Arabic and English. Right-to-left is a first-class layout, never an afterthought (docs/philosophy.md, Accessible and adaptive by default, which names right-to-left alignment among the release requirements). A theme is the right unit for that brief. A bank's brand guidelines pin down the accent, surfaces, radii, and spacing, while the controls stay Apple's own

MANGO commits to three brand characters: warmth, generosity, and calm. A mango-orange accent is spent once per screen on what you can act on. Radii and spacing are generous. A strokeless surface reads as depth, not division. These three words are the emotion the surface layer reinforces. Every token below serves one of them

## Conceptual model

A design system on this registry has five parts. The Layers order names them before the surface:

- The theme value: a `RegistryTheme`, a small `Sendable` struct of an optional `accent`, `onAccent`, `surface`, `border`, `positive`, `negative`, `disabledOpacity`, and `RegistryMetrics` (Sources/SwiftUIRegistryFoundations/RegistryTheme.swift)
- The environment: `@Entry` injects the theme. Apply it once with `registryTheme(_:)` at the scene root. It also tints Apple controls when the theme declares an accent (docs/architecture.md, Foundations)
- The presets: plain `static let` starting points (`system`, `graphite`, `indigo`, `rose`, `emerald`, `amber`), not a theme engine. MANGO adds `mango` as a seventh
- The code: the theme as one short shareable string, the registry's counterpart of shadcn's `--preset` codes. The tool, the Showcase, the website, and the MCP server all read and write it (docs/registry-spec.md, Preset codes)
- The owned copies: items copied into the app and tracked by a receipt, edited in place, audited with `--diff` (docs/architecture.md, Installation behavior)

What it is not: a design system here is not a new item kind. A theme does not install as a `theme` item. The preset code already round-trips through the tool, the Showcase, the website, and the MCP server. `RegistryTheme+App.swift` carries no receipt entry, and the installer never touches it (docs/registry-spec.md, Preset codes, "The theme file is not a registry item"). shadcn ships `registry:theme` items only because CSS variables must be installed as files. A Swift value in the environment does not need that

## Surface

### Tokens

Every custom color carries a light and dark pair, so it stays readable on both grounds. Values not listed inherit the `RegistryMetrics` and `RegistryTheme` defaults (Sources/SwiftUIRegistryFoundations/RegistryTheme.swift):

| Token | Value | Why |
|---|---|---|
| accent | light `#FFA033`, dark `#FFB84D` | the mango; a separate dark pair keeps the accent readable on black |
| onAccent | `.black` (`darkLabelOnAccent: true`) | a light accent needs a dark label, the `amber` precedent (RegistryTheme.swift line 124) |
| surface | `.primary.opacity(0.07)` | depth from a surface luminance step |
| border | `.primary.opacity(0)` | strokeless, border opacity zero |
| borderWidth, emphasizedBorderWidth | 1, 2 | unchanged defaults |
| compactRadius, controlRadius, cardRadius | 10, 14, 24 | generous radii that pair with rounded type |
| compactSpacing, standardSpacing, sectionSpacing | 8, 16, 28 | one step more air between sections |
| controlHorizontalPadding | 16 | wider controls |
| disabledOpacity | 0.4 | slightly stronger dimming |
| positive, negative | `.green`, `.red` | defaults, never part of a code |

### Typography

MANGO applies `Font.Design.rounded` once at the root of a MANGO scene with `.fontDesign(.rounded)`, to match the generous radii. This is not a theme field, so the preset code format does not change for it. Every value that can change carries `.monospacedDigit()`, so digits do not shift width as they update

### The strokeless surface step

MANGO sets `border` to `.primary.opacity(0)` and uses `surface` at `0.07` for hierarchy. Depth comes from a luminance step in the fill, not a hairline. The `border` token stays in foundations for shadcn parity and for themes that do want a hairline. MANGO sets it to nothing

### Motion

MANGO's motion comes from Emil Kowalski's `apple-design` skill. This template uses that skill as the example of the system extended with an outside skill. Three of its principles carry over to SwiftUI without translation:

- Springs by damping and response, not duration: MANGO's default is `.spring(response: 0.4, dampingFraction: 1.0)`, critically damped with no overshoot. It uses `dampingFraction: 0.8` only after a gesture that carried momentum ("Start most UI at damping 1.0", "Add bounce (damping ~0.8) only when the gesture itself carried momentum"; apple-design skill, section 4, "Behavior over animation")
- Feedback on press, not release: the button style scales to 0.97 on `isPressed`, applied on press ("Respond on pointer-down, not on release"; apple-design skill, section 1, "Response")
- Reduced motion is a cross-fade, not no feedback: when `accessibilityReduceMotion` is on, transitions become `.opacity` cross-fades with no movement ("replace slides/springs/parallax with short opacity cross-fades"; apple-design skill, section 14, "Reduced motion and accessibility")

### The MANGO preset code

The codec produces the code. Do not type it by hand. Write the `RegistryTheme` value and run `swiftui-registry preset resolve <path>`, or encode the tuning through RegistryKit's `Preset` (docs/registry-spec.md, Preset codes). MANGO's code is `a74hGF01CVunaG0vzZJG`, pinned in `Registry/preset_vectors.json`. All three codecs reproduce it byte for byte through that file (docs/registry-spec.md, Preset codes)

## Do the same for your brand

Each step names the file it produces (commands from README.md, Examples/TodoCounter/README.md, and docs/registry-spec.md, Preset codes and Agent usage):

1. Apply a starting code: `swiftui-registry preset apply <code> --destination <dir>` writes `RegistryTheme+App.swift`. This extension declares `RegistryTheme.app` to apply once at your scene root
2. Edit the theme: change the accent, radii, surface, and spacing in `RegistryTheme+App.swift` until the brand fits
3. Read the code back: `swiftui-registry preset resolve <path-to-RegistryTheme+App.swift>` parses the initializer and prints your new shareable code (it never trusts the file header)
4. Install an item: `swiftui-registry install <item> --destination <dir>` copies the item source and writes `.swiftui-registry/receipt.json`
5. Edit the owned copy: change the installed file in place. It is your source now
6. Audit the edit: `swiftui-registry install <item> --diff --destination <dir>` prints a unified diff of your copy against the canonical registry source (exit 0 on parity, 1 on differences)
7. Take upstream change later: `swiftui-registry install <item> --destination <dir> --update` merges registry updates into your copy with `git merge-file` and keeps your edits. It writes a `.merge` artifact only on a real conflict
8. Share the look: open the Create page at `?preset=<code>` to show the tokens. In the Showcase, tap Copy Code to put the code on the pasteboard, and Import to load a code back into the tuning panel

## What MANGO customized in the Showcase

The Showcase keeps the canonical installed items under `Examples/Showcase/SwiftUIRegistryShowcasePackage/Sources/SwiftUIRegistryShowcaseFeature/Installed/`. They stay byte-identical to the registry source for `--diff` and the generator freshness tests (docs/architecture.md, Installation behavior and Presentation policy). MANGO's customized copies live beside them under `.../SwiftUIRegistryShowcaseFeature/Mango/`. Each copy has renamed types and a header comment. The comment names the item and version they came from and every edit made:

- `MangoButtonStyle`: a copy of the `button` item's style with MANGO's motion. It carries the press feedback (scale 0.97 on `isPressed`, applied on press) and the critically damped spring, with a cross-fade under Reduce Motion (Surface, Motion above)
- `MangoMetricCard`: a copy of the `metric-card` item with `.monospacedDigit()` on its changing value, so the number does not jump width as it updates (Surface, Typography above)

They are renamed in the Showcase because the app also consumes the untouched originals under `Installed/`. Two types with the same name cannot coexist in one target. A consumer app instead has only its own copy and edits it in place. There, `swiftui-registry install <item> --diff` shows the change against canonical (docs/architecture.md, Installation behavior; Examples/TodoCounter/README.md, the `RegistryBadge` edit)
