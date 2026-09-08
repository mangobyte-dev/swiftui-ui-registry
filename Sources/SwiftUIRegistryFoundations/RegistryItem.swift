import SwiftUI

/// What a design surface tells the registry items below it. `nil`, the
/// default, means no surface is present, and ``SwiftUI/View/registryItem(_:)``
/// leaves its content untouched apart from an empty overlay.
public struct RegistryItemSurface: Equatable, Sendable {
    /// The name of the item the surface has selected, or `nil`.
    public var selected: String?

    public init(selected: String? = nil) {
        self.selected = selected
    }
}

/// One item root's frame, reported to a surface through
/// ``RegistryItemAnchorsKey`` so a tap can pick the innermost item under it
/// without the items competing for the gesture.
public struct RegistryItemAnchor {
    public let name: String
    public let bounds: Anchor<CGRect>

    public init(name: String, bounds: Anchor<CGRect>) {
        self.name = name
        self.bounds = bounds
    }
}

public struct RegistryItemAnchorsKey: PreferenceKey {
    public static var defaultValue: [RegistryItemAnchor] { [] }

    public static func reduce(value: inout [RegistryItemAnchor], nextValue: () -> [RegistryItemAnchor]) {
        value += nextValue()
    }
}

public extension EnvironmentValues {
    @Entry var registryItemSurface: RegistryItemSurface? = nil
}

public extension View {
    /// Names the registry item whose root this view is, so a design surface
    /// can select it on device: while a surface is present the root reports
    /// its frame and draws a selection ring and its name when selected.
    /// Without a surface the modifier adds nothing a user or a test can see.
    /// Every installable item applies it once, at the end of its root view's
    /// or style's modifier chain.
    nonisolated func registryItem(_ name: String) -> some View {
        modifier(RegistryItemModifier(name: name))
    }
}

private struct RegistryItemModifier: ViewModifier {
    @Environment(\.registryItemSurface) private var surface
    @Environment(\.registryTheme) private var theme
    let name: String

    func body(content: Content) -> some View {
        content.overlay {
            if let surface {
                Color.clear
                    .anchorPreference(key: RegistryItemAnchorsKey.self, value: .bounds) { bounds in
                        [RegistryItemAnchor(name: name, bounds: bounds)]
                    }
                    .overlay(alignment: .topLeading) {
                        if surface.selected == name {
                            selection
                        }
                    }
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
        }
    }

    private var selection: some View {
        let ring = RoundedRectangle(cornerRadius: theme.metrics.controlRadius, style: .continuous)
        let accent = theme.accent ?? Color.accentColor
        return ring
            .stroke(accent, lineWidth: theme.metrics.emphasizedBorderWidth)
            .overlay(alignment: .topLeading) {
                Text(name)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(theme.onAccent)
                    .padding(.horizontal, theme.metrics.compactSpacing / 2)
                    .background(accent, in: Capsule())
                    .offset(y: -theme.metrics.compactSpacing)
            }
    }
}
