import SwiftUI

/// The small, stable design contract shared by source-owned registry items.
///
/// Set it once at the root of a scene with ``SwiftUI/View/registryTheme(_:)``
/// and every registry item below inherits the same accent, surfaces, borders,
/// semantic colors, and metrics. Apple controls still read the app tint, so a
/// theme with an ``accent`` also tints native buttons, toggles, and pickers.
public struct RegistryTheme: Sendable {
    /// The interactive accent applied as the subtree tint. `nil` inherits the
    /// app tint already in the environment instead of replacing it.
    public var accent: Color?
    /// The foreground drawn on top of accent-filled controls, such as the
    /// primary button label. Pair it with the accent's luminance.
    public var onAccent: Color
    /// The content-layer surface fill used by cards and secondary controls.
    public var surface: Color
    /// The hairline stroke used by surfaces, inputs, and separators.
    public var border: Color
    /// Success and completion semantics.
    public var positive: Color
    /// Error and destructive semantics. Registry buttons draw a white label
    /// on this fill, so keep it dark enough for white text.
    public var negative: Color
    /// Opacity applied to disabled registry controls.
    public var disabledOpacity: Double
    public var metrics: RegistryMetrics

    public init(
        accent: Color? = nil,
        onAccent: Color = .white,
        surface: Color = .primary.opacity(0.055),
        border: Color = .primary.opacity(0.08),
        positive: Color = .green,
        negative: Color = .red,
        disabledOpacity: Double = 0.5,
        metrics: RegistryMetrics = .init()
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
    /// Radius of small chrome such as badges and checkboxes.
    public var compactRadius: CGFloat
    public var controlRadius: CGFloat
    public var cardRadius: CGFloat

    public init(
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

// MARK: - Presets

/// A named starting point for a design system. Pick one, apply it once, then
/// edit the copied item source or override individual tokens as the product
/// diverges.
public struct RegistryThemePreset: Identifiable, Sendable {
    public var id: String { name }
    public let name: String
    public let theme: RegistryTheme

    public init(name: String, theme: RegistryTheme) {
        self.name = name
        self.theme = theme
    }
}

public extension RegistryTheme {
    /// Inherits the app tint and the system's semantic colors. The default.
    static let system = RegistryTheme()

    /// Monochrome: primary-colored accent with a background-colored label, the
    /// familiar black-on-light, white-on-dark treatment.
    static let graphite = RegistryTheme(
        accent: .primary,
        onAccent: systemBackground,
        surface: .primary.opacity(0.05),
        border: .primary.opacity(0.1)
    )

    static let indigo = RegistryTheme(accent: .indigo)

    static let rose = RegistryTheme(accent: .pink)

    static let emerald = RegistryTheme(accent: .green)

    /// A light accent that needs a dark label; proves ``onAccent`` earns its place.
    static let amber = RegistryTheme(accent: .yellow, onAccent: .black)

    /// Every preset in display order.
    static let presets: [RegistryThemePreset] = [
        RegistryThemePreset(name: "System", theme: .system),
        RegistryThemePreset(name: "Graphite", theme: .graphite),
        RegistryThemePreset(name: "Indigo", theme: .indigo),
        RegistryThemePreset(name: "Rose", theme: .rose),
        RegistryThemePreset(name: "Emerald", theme: .emerald),
        RegistryThemePreset(name: "Amber", theme: .amber),
    ]

    /// The platform window background, used as the label on a primary-colored accent.
    private static var systemBackground: Color {
        #if canImport(UIKit)
        Color(uiColor: .systemBackground)
        #elseif canImport(AppKit)
        Color(nsColor: .windowBackgroundColor)
        #else
        Color.white
        #endif
    }

    /// The preset whose name matches, case-insensitively, or `nil`.
    static func preset(named name: String) -> RegistryTheme? {
        presets.first { $0.name.caseInsensitiveCompare(name) == .orderedSame }?.theme
    }
}

// MARK: - Environment

public extension EnvironmentValues {
    @Entry var registryTheme = RegistryTheme()
}

public extension View {
    /// Applies registry foundations to this subtree: the tokens through the
    /// environment and, when the theme declares an accent, the tint as well.
    /// Apply once at the scene root for a set-up-once design system.
    ///
    /// The tint is applied only when an accent exists, because `tint(nil)`
    /// resets the tint instead of inheriting it and SwiftUI exposes no way to
    /// read the tint already in place. A theme whose accent changes between
    /// `nil` and a value at runtime therefore replaces the subtree and resets
    /// the state below it. Keep the accent's presence stable, or pass
    /// `Color.accentColor` instead of `nil`.
    func registryTheme(_ theme: RegistryTheme) -> some View {
        modifier(RegistryThemeModifier(theme: theme))
    }

    /// Applies the shared content-surface treatment used by registry cards.
    func registrySurface() -> some View {
        modifier(RegistrySurfaceModifier())
    }
}

private struct RegistryThemeModifier: ViewModifier {
    let theme: RegistryTheme

    @ViewBuilder
    func body(content: Content) -> some View {
        if let accent = theme.accent {
            content
                .environment(\.registryTheme, theme)
                .tint(accent)
        } else {
            content
                .environment(\.registryTheme, theme)
        }
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
