# Contributing

Start with `docs/philosophy.md` (why) and `docs/architecture.md` (how). Participation follows `CODE_OF_CONDUCT.md`; report vulnerabilities as described in `SECURITY.md`, never in a public issue

## Repository layout

| Path | What it is |
| --- | --- |
| `Sources/SwiftUIRegistryFoundations/` | the stable design-foundations package: theme, metrics, presets, and the item and screen hooks |
| `Sources/SwiftUIRegistryDesignSurface/` | the optional design-surface product: the on-device tuning panel, the preset codec, and `designSurface()` |
| `Sources/RegistryKit/`, `Sources/SwiftUIRegistryCLI/` | the SwiftUI-free engine and the `swiftui-registry` tool (loading, validation, install and merge, search, preset codes, the MCP server, the generators) |
| `Registry/items/` | machine-readable item metadata and the dependency graph |
| `Registry/sources/components/`, `Registry/sources/blocks/` | canonical source-owned components and blocks |
| `docs/` | the contracts and the generated `docs/catalog/` |
| `Examples/Showcase/` | the compile, integration, and visual consumer |
| `Examples/TodoCounter/` | a second consumer on the Composable Architecture |
| `Website/` | the Next.js registry website |
| `Skills/` | the three agent skills, mirrored to `~/.claude/skills/` |
| `Distribution/homebrew/` | the Homebrew formula template for the owner's tap |
| `Tests/` | the tool's command, installer, validator, preset, MCP, and generator contracts |

`AGENTS.md` is the full development guide; its Boundaries section is the authority on what each path owns

## Adding a registry item

1. Solve a product-composition problem above Apple's native controls
2. Keep inputs architecture-neutral and localizable
3. Add a focused preview covering realistic content and large-text behavior
4. Add item metadata with a semantic version, exact files, registry dependencies, platform floor, and accessibility notes
5. Install the item into `Examples/Showcase`, register its demo in `ItemDemos.swift`, and compile it at the deployment floor
6. Add dependency-resolution and search coverage when introducing a new item
7. Capture the item with `python3 Scripts/capture_previews.py <name>`, then regenerate the derived surfaces
8. Review the regular and accessibility-size states before changing a visual reference

## Before you open a pull request

Run the verification list in `AGENTS.md` (Verification), cheapest first, and name anything skipped. A change is incomplete if any generated consumer source differs from the registry source or any command fails. Avoid broad refactors, new dependencies, and generic control replacements in component changes
