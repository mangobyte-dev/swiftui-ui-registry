# Project principles

## Native first

Use Apple controls, containers, accessibility behavior, and platform adaptation. Keep the raw control visible at the call site. Standardize its appearance through SwiftUI style protocols or focused modifiers. Use a composition view only when it adds reusable structure around those primitives

## SwiftUI-shaped reuse

A separate `View` type is not automatically reusable. Configure reusable views with values, bindings, actions, and sensible defaults. Use these three tools:

- `@ViewBuilder` for containers that provide consistent structure or chrome around arbitrary content
- style protocols for consistent interactive appearance
- `ViewModifier` for independent optional behavior

## Source ownership where change is expected

You can copy product components, blocks, and flows into the app when a team expects to adapt them. Stable foundations can stay a package dependency when central updates are worth more than local ownership

## Progressive adoption

One item must be useful without adopting a catalog, architecture, theme engine, or service

## Architecture neutral

Views accept prepared values, bindings, and action closures. Controlled product state stays with the caller. A component can own transient `@State` only when the interaction is self-contained and no caller needs to coordinate it. Application state, navigation policy, persistence, networking, and dependency injection stay outside the UI layer

## Accessible and adaptive by default

System text styles, semantic color, VoiceOver semantics, right-to-left alignment, Reduce Motion compatibility, and intentional iPhone/iPad behavior are release requirements. Components respect Dynamic Type, color scheme, layout direction, enabled state, and parent layout proposals. Require accessibility input when the visible content cannot provide it

## Constrained customization

Expose a small semantic foundation and ordinary Swift source. Use semantic tokens instead of repeated hardcoded values. Add a token only after two real items need the same meaning. Prefer a focused modifier over expanding a component initializer with unrelated options. Avoid a universal styling abstraction. Consumers have four options:

- set the foundation once at a scene root
- tune it live in the Showcase and paste the result
- override the subtree where a screen differs
- edit copied code

## Evidence before extraction

A reusable abstraction needs two concrete consumers or named roadmap usages. Do not generalize a one-off layout speculatively

## Agent legible

Names, files, dependencies, platforms, accessibility behavior, previews, and composition examples must be explicit in machine-readable metadata

## Compile and visually verified

A registry item is publishable only when its dependency closure installs into a consumer and compiles at the declared deployment floor. Important compositions also need current previews and bounded device-class review

## Apple inherits first

Do not imitate a new platform treatment. Recompile with the current SDK. Remove competing custom chrome. Let native primitives adopt platform changes before you add compatibility code

### Liquid Glass boundaries

Registry styles and the `registrySurface` and theme tokens are content-layer treatments. Never apply them to toolbars, tab bars, or floating chrome, where the system supplies Liquid Glass on its own. When you promote a functional button into floating or bar chrome, use `.buttonStyle(.glass)`, or `.buttonStyle(.glassProminent)` for a single primary action, instead of `.registry` styles

The reusable-component rules above are grounded in [SwiftQA, “How do you design reusable SwiftUI components?”](https://swiftqa.cc/reusable-swiftui-components)
