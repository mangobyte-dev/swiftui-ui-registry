# Project principles

## Native first

Apple controls/containers: accessible, adaptive, visible; protocol/modifier-styled. Composition: reusable structure.

## SwiftUI-shaped reuse

`View` isn't automatically reusable; configure values, bindings, actions, defaults:

- `@ViewBuilder`: chrome, content
- style protocol: appearance
- `ViewModifier`: behavior

## Source ownership where change is expected

Copy components/blocks/flows; foundations stay dependency.

## Progressive adoption

MUST work without catalog, architecture, theme engine, service.

## Architecture neutral

Views: values, bindings, closures, caller state. `@State` transient if self-contained. Elsewhere: app-state, navigation, persistence, networking, DI.

## Accessible and adaptive by default

Adaptive type, semantic color, VoiceOver, right-to-left, Reduce Motion, iPhone/iPad, color scheme, layout proposals, enabled state. Accessibility input when absent.

## Constrained customization

Semantic foundation, Swift source; tokens > hardcoded (2-item threshold). Modifier > initializer, no universal abstraction. Root default, Showcase tune, subtree override, edit.

## Evidence before extraction

Abstraction needs 2 consumers, roadmap uses; MUST NOT generalize one-off layouts.

## Agent legible

MUST be explicit machine-readable metadata: names, files, dependencies, platforms, accessibility, previews, examples.

## Compile and visually verified

Publishable: closure installs, compiles at floor. Compositions: previews, device-class review.

## Apple inherits first

MUST NOT imitate new treatment: recompile SDK, drop competing chrome; natives adopt changes before compatibility code.

### Liquid Glass boundaries

Registry styles, `registrySurface`, theme tokens: content-layer, not toolbars/bars/floating chrome. Button: `.buttonStyle(.glass)`; primary: `.buttonStyle(.glassProminent)`, not `.registry`.

[SwiftQA](https://swiftqa.cc/reusable-swiftui-components).
