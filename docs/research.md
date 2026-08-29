# Research and thesis challenge

Research checked 2026-08-29 against public first-party pages, repositories, installed SDK declarations, and Xcode-exported Apple guidance

## Executive conclusion

The original thesis is directionally right but too absolute. SwiftUI does not lack component libraries, copy-paste templates, AI-oriented recipes, or even a shadcn-style source installer. Those all exist. The unresolved opportunity is a trusted, native-first registry centered on product composition, with compile evidence, accessibility metadata, architecture-neutral APIs, source provenance, and an ecosystem that does not begin by replacing Apple's controls

No reviewed project yet establishes a dominant standard across all of those properties. That is the narrower thesis version 0 should test

## Web architecture lessons

- shadcn/ui describes itself as a code distribution platform rather than a conventional component package. Its registry item format separates registry dependencies from package dependencies and identifies source files. Its MCP server exposes registry browsing, search, and installation to assistants. Sources: [introduction](https://ui.shadcn.com/docs), [registry item schema](https://ui.shadcn.com/docs/registry/registry-item-json), [registry schema](https://ui.shadcn.com/docs/registry/registry-json), [MCP server](https://ui.shadcn.com/docs/mcp)
- shadcn Blocks prove that composed pages can be distributed through the same source mechanism, with multiple files and registry dependencies. Source: [shadcn Blocks](https://ui.shadcn.com/blocks)
- Base UI and Radix solve low-level web behavior because the web platform often lacks sufficiently consistent, accessible primitives. SwiftUI's starting point is different because Apple already owns those controls and behaviors. Sources: [Base UI about](https://base-ui.com/react/overview/about), [Radix introduction](https://www.radix-ui.com/primitives/docs/overview/introduction)
- 21st.dev extends source ownership into a multi-author registry, templates, themes, previews, and AI-ready prompts. This shows that distribution plus discovery and visual curation can become a marketplace layer. Source: [21st.dev](https://21st.dev)

What transfers: source ownership, explicit dependency graphs, deterministic names, blocks above components, preview evidence, and agent-readable discovery

What does not transfer: rebuilding native controls, web-style variant matrices, Tailwind token assumptions, DOM accessibility repairs, and framework-specific file placement

## Adjacent SwiftUI projects

### ComponentsKit and ComponentsKit Pro

ComponentsKit is an MIT Swift package for iOS 15 with a UIKit and SwiftUI control catalog. Its public list includes button, checkbox, segmented control, slider, inputs, modals, and cards. Pro sells copy-paste SwiftUI pages for settings, paywalls, profiles, and authentication. Strength: polished documentation and a clear free-package plus paid-blocks ladder. Weakness for this thesis: much of the free layer recreates controls Apple already supplies, and package distribution does not provide source ownership. Sources: [repository](https://github.com/componentskit/ComponentsKit), [Pro](https://componentskit.io/pro)

### ShipSwift

ShipSwift is the closest broad competitor found. Its MIT repository provides file-copy source, an MCP recipe server, installable agent skills, a showcase app, components, charts, animations, and multi-file modules. Strength: AI consumption and real source are first-class. Weakness for this thesis: the scope mixes UI, shaders, camera, authentication, paywalls, backend recipes, and services, so it is not a narrow composition standard; its public installation model is file or recipe oriented rather than a local, typed registry dependency contract. Source: [ShipSwift repository](https://github.com/signerlabs/ShipSwift)

### swiftcn

swiftcn directly ports the shadcn distribution idea: a Node CLI copies Swift files, installs a theme, and reads a JSON registry. It supports six components and optional server-driven UI. Strength: it proves source copying and dependency-free ownership are feasible. Weakness for this thesis: its initial catalog centers on Button, Switch, Slider, Input, Card, and Badge with web-like variants, exactly where a native-first project should defer to Apple. Sources: [swiftcn repository](https://github.com/Dicky019/swiftcn), [registry](https://github.com/Dicky019/swiftcn/blob/main/CLI/registry.json)

### SwiftUI Portal

SwiftUI Portal sells current iOS 26 templates with source and context files intended to keep coding agents on current APIs. Strength: it recognizes model training lag as a product problem. Weakness: it is a commercial template catalog rather than an open registry protocol or neutral foundation. Source: [SwiftUI Portal](https://swiftuiportal.com)

### Basics

Basics offers SwiftUI templates that developers copy and customize, including authentication and settings. Strength: direct source ownership and useful screen scope. Weakness: it is a template site rather than a dependency-aware registry, and its published license restricts redistribution as competing template products. Source: [Basics](https://swiftuibasics.com)

### DockUI

DockUI combines a SwiftUI template library, visual studio, and native code export. Strength: designer-facing code generation and immediate ownership. Weakness: public material does not establish an open machine-readable registry, dependency model, accessibility contract, or compile matrix. Source: [DockUI](https://dockui.com)

### ChunUI

ChunUI is an MIT Swift package extracted from a production app, with a cohesive monochrome design system, many effects, one third-party dependency, a gallery, and an agent skill. Strength: a strong visual point of view and agent guidance. Weakness: it is an aesthetic package ecosystem rather than source-owned, brand-neutral product composition. Source: [ChunUI repository](https://github.com/liseami/ChunUI)

### DesignFoundation

DesignFoundation is an MIT package with tokens, themes, style protocols, and more than 30 components across controls, navigation, overlays, and layout. Strength: coherent environment-driven customization and tests. Weakness: breadth creates a framework adoption decision and includes replacements for controls and navigation that this project should leave to SwiftUI. Source: [DesignFoundation repository](https://github.com/NerdSnipe-Inc/design-foundation)

### Names not verified

No public project matching the exact requested names Nibware, SwiftUX, or Compot could be verified through exact GitHub repository searches or the supplied public-name searches during this session. They are not scored rather than being described from assumptions

## Apple guidance that shapes the design

- `View` is Apple's composition unit; `ButtonStyle` customizes native button behavior; `Layout` defines geometry; and `EnvironmentValues` propagates values through a hierarchy. Sources: [View](https://developer.apple.com/documentation/swiftui/view), [ButtonStyle](https://developer.apple.com/documentation/swiftui/buttonstyle), [Layout](https://developer.apple.com/documentation/swiftui/layout), [EnvironmentValues](https://developer.apple.com/documentation/swiftui/environmentvalues)
- Observation is available from iOS 17, but registry views do not need to own observable application models. Source: [Observable](https://developer.apple.com/documentation/observation/observable)
- Swift Testing is available with Swift 6 and Xcode 16. Source: [Swift Testing](https://developer.apple.com/documentation/testing)
- Apple describes materials as a hierarchy and depth mechanism, not general decoration. This slice therefore uses semantic content surfaces and no custom glass. Source: [HIG Materials](https://developer.apple.com/design/human-interface-guidelines/materials)
- Accessibility is a baseline product requirement. The slice uses system text styles, semantic colors, native buttons, decorative-image hiding, combined VoiceOver elements, and flexible fit behavior. Source: [HIG Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)

The installed Xcode 27 export additionally recommends separate `View` types as invalidation boundaries, narrow value inputs, `@Entry` for custom environment values, `LocalizedStringResource` for user-facing API values, leading/trailing alignment for right-to-left layouts, and Swift Testing. Those exported files were generated locally with `xcrun agent skills export` and are intentionally excluded from the repository because they belong to the installed Xcode toolchain

## Point-Free lessons

Point-Free's ecosystem supports the architectural thesis through separation rather than one umbrella import:

- TCA focuses on feature state and behavior: [swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture)
- Dependencies is independently useful for controllable dependencies and previews: [swift-dependencies](https://github.com/pointfreeco/swift-dependencies)
- Navigation focuses on state-driven navigation while retaining SwiftUI presentation APIs: [swift-navigation](https://github.com/pointfreeco/swift-navigation)
- Sharing focuses on shared state and persistence strategies: [swift-sharing](https://github.com/pointfreeco/swift-sharing)
- SQLiteData owns querying and persistence: [SQLiteData](https://github.com/pointfreeco/sqlite-data)
- SnapshotTesting is a standalone generalized test tool: [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing)

The lesson is not to copy their APIs. It is to keep responsibilities narrow, make each layer independently useful, compose through explicit dependencies, and keep testing and documentation beside each module

## Thesis challenge

1. **Is there a missing problem?** Yes, but it is a quality and coordination gap, not an empty market
2. **Does an existing project solve it?** ShipSwift, swiftcn, ComponentsKit Pro, Portal, Basics, and DockUI each solve meaningful subsets. None reviewed combines the full native-first registry contract
3. **Why no dominant solution?** SwiftUI already supplies strong controls, product UI is domain-specific, source copying complicates updates, Xcode project integration is less uniform than web file systems, and visual taste is harder to standardize than control behavior
4. **Which shadcn ideas fit?** Source ownership, registry dependencies, deterministic installation, blocks, visual examples, and agent discovery
5. **Which do not fit?** Rebuilding controls, variant-heavy web APIs, DOM primitive layers, CSS variable assumptions, and line-for-line schema copying
6. **What remains Apple's responsibility?** Controls, navigation, presentations, accessibility semantics, input behavior, platform adaptation, materials, animation primitives, localization mechanics, and OS visual evolution
7. **What should this project own?** Semantic foundations, product components, blocks, flows, registry metadata, provenance, examples, and compile/visual conformance
8. **Is source copying appropriate?** Yes for product UI expected to change. No as a universal rule for stable shared mechanics
9. **Should foundations remain a package?** Version 0 says yes, narrowly. The copied layer imports one stable foundation product
10. **How do copied items receive tokens?** Through a small `RegistryTheme` environment value. Consumers may override it or edit their owned source
11. **How does architecture neutrality hold?** Inputs are prepared values, IDs, bindings when needed, and actions. No stores or persistence types cross the boundary
12. **How do copied components evolve?** Independently after installation. Registry releases provide new reference source, not remote control
13. **How should updates work?** Exact-content receipts plus three-way comparison. Version 0 now preserves local-only edits, merges disjoint edits, and stops on overlap
14. **Why better than snippets?** Dependency closure, platform floor, package requirements, accessibility notes, previews, deterministic names, and compile proof
15. **How do apps avoid sameness?** Keep foundations semantic and small, make higher-level source editable, and publish multiple domain compositions rather than one global skin
16. **Why useful to teams?** Reviewable source, declared boundaries, compile evidence, accessibility intent, provenance, and no forced app architecture
17. **How are Apple changes inherited?** Native primitives stay in place and custom chrome stays out. Recompile first, then adapt only demonstrated gaps
18. **What changes with AI-native distribution?** Metadata becomes an executable design contract. Agents can select known items, resolve dependencies, inspect examples, and compile instead of inventing arbitrary UI

## Decision carried into version 0

Build a narrow package foundation plus copied product components and blocks. Prove installation and compilation before investing in CLI polish, remote hosting, MCP, Figma, premium catalogs, or broad component count
