import SwiftUI

/// The registry's button treatment, rewritten by hand for the comparison.
struct HandmadeButtonStyle: ButtonStyle {
    enum Variant: Sendable {
        case primary
        case destructive
        case outline
        case secondary
        case ghost
    }

    @Environment(\.controlSize) private var controlSize
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.handmadeTheme) private var theme

    private let variant: Variant

    init(_ variant: Variant = .primary) {
        self.variant = variant
    }

    func makeBody(configuration: Configuration) -> some View {
        let variant = resolvedVariant(for: configuration)
        let isDestructiveRole = configuration.role == .destructive
        let shape = RoundedRectangle(cornerRadius: theme.metrics.controlRadius, style: .continuous)

        configuration.label
            .font(font)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(minHeight: visualMinimumHeight)
            .foregroundStyle(foregroundStyle(for: variant, isDestructiveRole: isDestructiveRole))
            .background(backgroundStyle(for: variant, isPressed: configuration.isPressed), in: shape)
            .overlay {
                shape.stroke(
                    borderStyle(for: variant, isDestructiveRole: isDestructiveRole),
                    lineWidth: variant == .outline ? theme.metrics.borderWidth : 0
                )
            }
            .opacity(opacity(isPressed: configuration.isPressed))
            .frame(minWidth: HandmadeMetrics.minimumHitSize, minHeight: HandmadeMetrics.minimumHitSize)
            .contentShape(Rectangle())
    }
}

extension ButtonStyle where Self == HandmadeButtonStyle {
    static var handmade: HandmadeButtonStyle { HandmadeButtonStyle() }
    static var handmadeDestructive: HandmadeButtonStyle { HandmadeButtonStyle(.destructive) }
    static var handmadeOutline: HandmadeButtonStyle { HandmadeButtonStyle(.outline) }
    static var handmadeSecondary: HandmadeButtonStyle { HandmadeButtonStyle(.secondary) }
    static var handmadeGhost: HandmadeButtonStyle { HandmadeButtonStyle(.ghost) }
}

private extension HandmadeButtonStyle {
    func resolvedVariant(for configuration: Configuration) -> Variant {
        if variant == .primary, configuration.role == .destructive {
            return .destructive
        }
        return variant
    }

    var font: Font {
        switch controlSize {
        case .mini: .caption2.weight(.medium)
        case .small: .caption.weight(.medium)
        case .regular: .subheadline.weight(.medium)
        case .large, .extraLarge: .body.weight(.medium)
        @unknown default: .subheadline.weight(.medium)
        }
    }

    var horizontalPadding: CGFloat {
        switch controlSize {
        case .mini: 8
        case .small: 12
        case .regular: 16
        case .large: 20
        case .extraLarge: 24
        @unknown default: 16
        }
    }

    var verticalPadding: CGFloat {
        switch controlSize {
        case .mini: 4
        case .small: 6
        case .regular: 8
        case .large: 10
        case .extraLarge: 12
        @unknown default: 8
        }
    }

    var visualMinimumHeight: CGFloat {
        switch controlSize {
        case .mini: 24
        case .small: 32
        case .regular: 36
        case .large: 40
        case .extraLarge: 44
        @unknown default: 36
        }
    }

    func foregroundStyle(for variant: Variant, isDestructiveRole: Bool) -> AnyShapeStyle {
        switch variant {
        case .primary: AnyShapeStyle(theme.onAccent)
        case .destructive: AnyShapeStyle(Color.white)
        case .outline, .secondary, .ghost:
            AnyShapeStyle(isDestructiveRole ? theme.negative : Color.primary)
        }
    }

    func backgroundStyle(for variant: Variant, isPressed: Bool) -> AnyShapeStyle {
        switch variant {
        case .primary: AnyShapeStyle(TintShapeStyle())
        case .destructive: AnyShapeStyle(theme.negative)
        case .secondary: AnyShapeStyle(theme.surface)
        case .outline, .ghost: AnyShapeStyle(isPressed ? theme.surface : Color.clear)
        }
    }

    func borderStyle(for variant: Variant, isDestructiveRole: Bool) -> Color {
        guard variant == .outline else { return .clear }
        return isDestructiveRole ? theme.negative : theme.border
    }

    func opacity(isPressed: Bool) -> Double {
        guard isEnabled else { return theme.disabledOpacity }
        return isPressed ? 0.82 : 1
    }
}
