import SwiftUI

enum HandmadeBadgeVariant: Sendable {
    case primary
    case secondary
    case outline
    case positive
    case destructive
}

extension View {
    /// The registry badge, rewritten by hand with the app's uppercase customization.
    func handmadeBadge(_ variant: HandmadeBadgeVariant = .primary) -> some View {
        modifier(HandmadeBadgeModifier(variant: variant))
    }
}

private struct HandmadeBadgeModifier: ViewModifier {
    @Environment(\.handmadeTheme) private var theme

    let variant: HandmadeBadgeVariant

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: theme.metrics.compactRadius, style: .continuous)

        content
            .font(.caption.weight(.semibold))
            .textCase(.uppercase)
            .lineLimit(1)
            .fixedSize()
            .foregroundStyle(foregroundStyle)
            .padding(.horizontal, theme.metrics.compactSpacing)
            .padding(.vertical, theme.metrics.compactSpacing / 2)
            .background(backgroundStyle, in: shape)
            .overlay {
                shape.stroke(
                    variant == .outline ? theme.border : .clear,
                    lineWidth: variant == .outline ? theme.metrics.borderWidth : 0
                )
            }
    }

    private var foregroundStyle: AnyShapeStyle {
        switch variant {
        case .primary: AnyShapeStyle(TintShapeStyle())
        case .secondary, .outline: AnyShapeStyle(Color.primary)
        case .positive: AnyShapeStyle(theme.positive)
        case .destructive: AnyShapeStyle(theme.negative)
        }
    }

    private var backgroundStyle: AnyShapeStyle {
        switch variant {
        case .primary: AnyShapeStyle(TintShapeStyle().opacity(0.14))
        case .secondary: AnyShapeStyle(theme.surface)
        case .outline: AnyShapeStyle(Color.clear)
        case .positive: AnyShapeStyle(theme.positive.opacity(0.14))
        case .destructive: AnyShapeStyle(theme.negative.opacity(0.14))
        }
    }
}
