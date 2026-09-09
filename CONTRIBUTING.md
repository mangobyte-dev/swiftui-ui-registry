# Contributing

Read `docs/philosophy.md` (why), `docs/architecture.md` (how). Follows `CODE_OF_CONDUCT.md`; vulnerabilities per `SECURITY.md`, not public

## Repository layout

| Path | Purpose |
| --- | --- |
| `Sources/SwiftUIRegistryFoundations/` | design-foundations package |
| `Sources/SwiftUIRegistryDesignSurface/` | design-surface product |
| `Sources/RegistryKit/`, `Sources/SwiftUIRegistryCLI/` | SwiftUI-free engine, `swiftui-registry` tool |
| `Registry/items/` | item metadata, dependency graph |
| `Registry/sources/components/`, `Registry/sources/blocks/` | components, blocks |
| `docs/` | contracts, catalog |
| `Examples/Showcase/` | compile, integration, visual consumer |
| `Examples/TodoCounter/` | second consumer, TCA |
| `Website/` | Next.js website |
| `Skills/` | agent skills, mirrored `~/.claude/skills/` |
| `Distribution/homebrew/` | Homebrew formula, owner's tap |
| `Tests/` | tool contracts |

`AGENTS.md`: dev guide. Boundaries: ownership

## Adding items

1. Solve product-composition above Apple's controls
2. Architecture-neutral, localizable inputs
3. Preview: realistic content, large-text
4. Metadata: version, exact files, dependencies, platform floor, accessibility notes
5. Install `Examples/Showcase`, register `ItemDemos.swift`, compile deployment floor
6. Dependency-resolution, search coverage
7. Capture `python3 Scripts/capture_previews.py <name>`, regenerate surfaces
8. Review regular, accessibility-size states before visual-reference changes

## Before PR

Run `AGENTS.md` Verification cheapest-first; name skips. Incomplete: source drifts, command fails. MUST NOT: broad refactors, dependencies, control replacements
