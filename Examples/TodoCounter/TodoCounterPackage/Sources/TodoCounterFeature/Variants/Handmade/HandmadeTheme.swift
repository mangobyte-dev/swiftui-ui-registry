import SwiftUI

/// The same design contract the registry ships, written by hand: the tokens every
/// handmade style reads, an environment key to carry them, and the surface treatment.
struct HandmadeTheme: Sendable {
    var accent: Color?
    var onAccent: Color
    var surface: Color
    var border: Color
    var positive: Color
    var negative: Color
    var disabledOpacity: Double
    var metrics: HandmadeMetrics

    init(
        accent: Color? = nil,
        onAccent: Color = .white,
        surface: Color = .primary.opacity(0.055),
        border: Color = .primary.opacity(0.08),
        positive: Color = .green,
        negative: Color = .red,
        disabledOpacity: Double = 0.5,
        metrics: HandmadeMetrics = HandmadeMetrics()
    ) {
        self.accent = accent
        self.onAccent = onAccent
        self.surface = surface
        self.border = border
        self.positive = positive
        self.negative = negative
        self.disabledOpacity = disabledOpacity
        self.metrics = metrics
    }

    /// The coral theme the registry variant resolved to the code a2nH36tnmJHJAMzm.
    static let app = HandmadeTheme(
        accent: Color(red: 0.898, green: 0.361, blue: 0.231),
        surface: .primary.opacity(0.070),
        metrics: HandmadeMetrics(compactRadius: 8, controlRadius: 12, cardRadius: 20)
    )
}

struct HandmadeMetrics: Sendable {
    static let minimumHitSize: CGFloat = 44

    var compactSpacing: CGFloat
    var standardSpacing: CGFloat
    var sectionSpacing: CGFloat
    var controlHorizontalPadding: CGFloat
    var borderWidth: CGFloat
    var emphasizedBorderWidth: CGFloat
    var compactRadius: CGFloat
    var controlRadius: CGFloat
    var cardRadius: CGFloat

    init(
        compactSpacing: CGFloat = 8,
        standardSpacing: CGFloat = 16,
        sectionSpacing: CGFloat = 24,
        controlHorizontalPadding: CGFloat = 12,
        borderWidth: CGFloat = 1,
        emphasizedBorderWidth: CGFloat = 2,
        compactRadius: CGFloat = 6,
        controlRadius: CGFloat = 8,
        cardRadius: CGFloat = 16
    ) {
        self.compactSpacing = compactSpacing
        self.standardSpacing = standardSpacing
        self.sectionSpacing = sectionSpacing
        self.controlHorizontalPadding = controlHorizontalPadding
        self.borderWidth = borderWidth
        self.emphasizedBorderWidth = emphasizedBorderWidth
        self.compactRadius = compactRadius
        self.controlRadius = controlRadius
        self.cardRadius = cardRadius
    }
}

extension EnvironmentValues {
    @Entry var handmadeTheme = HandmadeTheme()
}

extension View {
    /// Applies the tokens to a subtree and, when the theme has an accent, the tint too.
    /// `tint(nil)` resets instead of inheriting, so the accent's presence must stay stable.
    func handmadeTheme(_ theme: HandmadeTheme) -> some View {
        modifier(HandmadeThemeModifier(theme: theme))
    }

    func handmadeSurface() -> some View {
        modifier(HandmadeSurfaceModifier())
    }
}

private struct HandmadeThemeModifier: ViewModifier {
    let theme: HandmadeTheme

    @ViewBuilder
    func body(content: Content) -> some View {
        if let accent = theme.accent {
            content
                .environment(\.handmadeTheme, theme)
                .tint(accent)
        } else {
            content
                .environment(\.handmadeTheme, theme)
        }
    }
}

private struct HandmadeSurfaceModifier: ViewModifier {
    @Environment(\.handmadeTheme) private var theme

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: theme.metrics.cardRadius, style: .continuous)
        content
            .background(theme.surface, in: shape)
            .overlay {
                shape.stroke(theme.border, lineWidth: theme.metrics.borderWidth)
            }
    }
}
