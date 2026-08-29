# Project principles

## Native first

Use Apple controls, containers, styles, accessibility behavior, and platform adaptation. Registry items should solve product composition above those primitives

## Source ownership where change is expected

Product components, blocks, and flows may be copied into the app when teams are expected to adapt them. Stable foundations may remain a package dependency when central updates are more valuable than local ownership

## Progressive adoption

One item must be useful without adopting a catalog, architecture, theme engine, or service

## Architecture neutral

Views accept prepared values, bindings, and action closures. Application state, navigation policy, persistence, networking, and dependency injection stay outside the UI layer

## Accessible and adaptive by default

System text styles, semantic color, VoiceOver semantics, right-to-left alignment, Reduce Motion compatibility, and intentional iPhone/iPad behavior are release requirements

## Constrained customization

Expose a small semantic foundation and ordinary Swift source. Avoid a universal styling abstraction. Consumers can override the foundation subtree or edit copied code

## Agent legible

Names, files, dependencies, platforms, accessibility behavior, previews, and composition examples must be explicit in machine-readable metadata

## Compile and visually verified

A registry item is publishable only when its dependency closure installs into a consumer and compiles at the declared deployment floor. Important compositions also need current previews and bounded device-class review

## Apple inherits first

Do not imitate a new platform treatment. Recompile with the current SDK, remove competing custom chrome, and let native primitives adopt platform changes before adding compatibility code
