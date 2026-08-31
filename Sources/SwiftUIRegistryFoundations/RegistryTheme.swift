import SwiftUI

/// The small, stable design contract shared by source-owned registry items.
public struct RegistryTheme {
    public var surface: Color
    public var border: Color
    public var positive: Color
    public var negative: Color
    public var disabledOpacity: Double
    public var metrics: RegistryMetrics

    public init(
        surface: Color = .primary.opacity(0.055),
        border: Color = .primary.opacity(0.08),
        positive: Color = .green,
        negative: Color = .red,
        disabledOpacity: Double = 0.5,
        metrics: RegistryMetrics = .init()
    ) {
        self.surface = surface
        self.border = border
        self.positive = positive
        self.negative = negative
        self.disabledOpacity = disabledOpacity
        self.metrics = metrics
    }
}

/// Layout and appearance values shared without imposing an app-wide theme system.
public struct RegistryMetrics: Equatable, Sendable {
    public static let minimumHitSize: CGFloat = 44

    public var compactSpacing: CGFloat
    public var standardSpacing: CGFloat
    public var sectionSpacing: CGFloat
    public var controlHorizontalPadding: CGFloat
    public var borderWidth: CGFloat
    public var emphasizedBorderWidth: CGFloat
    public var controlRadius: CGFloat
    public var cardRadius: CGFloat

    public init(
        compactSpacing: CGFloat = 8,
        standardSpacing: CGFloat = 16,
        sectionSpacing: CGFloat = 24,
        controlHorizontalPadding: CGFloat = 12,
        borderWidth: CGFloat = 1,
        emphasizedBorderWidth: CGFloat = 2,
        controlRadius: CGFloat = 8,
        cardRadius: CGFloat = 16
    ) {
        self.compactSpacing = compactSpacing
        self.standardSpacing = standardSpacing
        self.sectionSpacing = sectionSpacing
        self.controlHorizontalPadding = controlHorizontalPadding
        self.borderWidth = borderWidth
        self.emphasizedBorderWidth = emphasizedBorderWidth
        self.controlRadius = controlRadius
        self.cardRadius = cardRadius
    }
}

public extension EnvironmentValues {
    @Entry var registryTheme = RegistryTheme()
}

public extension View {
    /// Overrides registry foundations for this view subtree.
    func registryTheme(_ theme: RegistryTheme) -> some View {
        environment(\.registryTheme, theme)
    }

    /// Applies the shared content-surface treatment used by registry cards.
    func registrySurface() -> some View {
        modifier(RegistrySurfaceModifier())
    }
}

private struct RegistrySurfaceModifier: ViewModifier {
    @Environment(\.registryTheme) private var theme

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(
            cornerRadius: theme.metrics.cardRadius,
            style: .continuous
        )

        content
            .background(theme.surface, in: shape)
            .overlay {
                shape.stroke(theme.border, lineWidth: theme.metrics.borderWidth)
            }
    }
}
