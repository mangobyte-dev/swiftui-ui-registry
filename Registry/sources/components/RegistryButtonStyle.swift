import SwiftUI
import SwiftUIRegistryFoundations

/// A shadcn-inspired treatment for native SwiftUI buttons.
public struct RegistryButtonStyle: ButtonStyle {
    public enum Variant: Sendable {
        case primary
        case destructive
        case outline
        case secondary
        case ghost
        case link
    }

    @Environment(\.controlSize) private var controlSize
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.registryTheme) private var theme

    private let variant: Variant

    public init(_ variant: Variant = .primary) {
        self.variant = variant
    }

    public func makeBody(configuration: Configuration) -> some View {
        let variant = resolvedVariant(for: configuration)
        let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)

        configuration.label
            .font(font)
            .multilineTextAlignment(.center)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(minHeight: visualMinimumHeight)
            .foregroundStyle(foregroundStyle(for: variant))
            .background(backgroundStyle(for: variant, isPressed: configuration.isPressed), in: shape)
            .overlay {
                shape.stroke(borderStyle(for: variant), lineWidth: variant == .outline ? 1 : 0)
            }
            .underline(variant == .link)
            .opacity(opacity(isPressed: configuration.isPressed))
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
    }
}

public extension ButtonStyle where Self == RegistryButtonStyle {
    static var registry: RegistryButtonStyle { RegistryButtonStyle() }
    static var registryDestructive: RegistryButtonStyle { RegistryButtonStyle(.destructive) }
    static var registryOutline: RegistryButtonStyle { RegistryButtonStyle(.outline) }
    static var registrySecondary: RegistryButtonStyle { RegistryButtonStyle(.secondary) }
    static var registryGhost: RegistryButtonStyle { RegistryButtonStyle(.ghost) }
    static var registryLink: RegistryButtonStyle { RegistryButtonStyle(.link) }
}

private extension RegistryButtonStyle {
    func resolvedVariant(for configuration: Configuration) -> Variant {
        if variant == .primary, configuration.role == .destructive {
            return .destructive
        }
        return variant
    }

    var font: Font {
        switch controlSize {
        case .mini:
            .caption2.weight(.medium)
        case .small:
            .caption.weight(.medium)
        case .regular:
            .subheadline.weight(.medium)
        case .large, .extraLarge:
            .body.weight(.medium)
        @unknown default:
            .subheadline.weight(.medium)
        }
    }

    var horizontalPadding: CGFloat {
        switch controlSize {
        case .mini:
            8
        case .small:
            12
        case .regular:
            16
        case .large:
            20
        case .extraLarge:
            24
        @unknown default:
            16
        }
    }

    var verticalPadding: CGFloat {
        switch controlSize {
        case .mini:
            4
        case .small:
            6
        case .regular:
            8
        case .large:
            10
        case .extraLarge:
            12
        @unknown default:
            8
        }
    }

    var visualMinimumHeight: CGFloat {
        switch controlSize {
        case .mini:
            24
        case .small:
            32
        case .regular:
            36
        case .large:
            40
        case .extraLarge:
            44
        @unknown default:
            36
        }
    }

    func foregroundStyle(for variant: Variant) -> AnyShapeStyle {
        switch variant {
        case .primary, .destructive:
            AnyShapeStyle(Color.white)
        case .outline, .secondary, .ghost:
            AnyShapeStyle(Color.primary)
        case .link:
            AnyShapeStyle(TintShapeStyle())
        }
    }

    func backgroundStyle(for variant: Variant, isPressed: Bool) -> AnyShapeStyle {
        switch variant {
        case .primary:
            AnyShapeStyle(TintShapeStyle())
        case .destructive:
            AnyShapeStyle(theme.negative)
        case .secondary:
            AnyShapeStyle(theme.surface)
        case .outline, .ghost:
            AnyShapeStyle(isPressed ? theme.surface : Color.clear)
        case .link:
            AnyShapeStyle(Color.clear)
        }
    }

    func borderStyle(for variant: Variant) -> AnyShapeStyle {
        AnyShapeStyle(variant == .outline ? theme.border : Color.clear)
    }

    func opacity(isPressed: Bool) -> Double {
        guard isEnabled else { return 0.5 }
        return isPressed ? 0.82 : 1
    }
}

private struct RegistryButtonStylePreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button("Default") {}
                .buttonStyle(.registry)

            Button("Secondary") {}
                .buttonStyle(.registrySecondary)

            Button("Outline") {}
                .buttonStyle(.registryOutline)

            Button("Ghost") {}
                .buttonStyle(.registryGhost)

            Button("Destructive", role: .destructive) {}
                .buttonStyle(.registry)

            Button("Link") {}
                .buttonStyle(.registryLink)

            Button("Disabled") {}
                .buttonStyle(.registry)
                .disabled(true)
        }
        .padding()
    }
}

#Preview("Button Variants") {
    RegistryButtonStylePreview()
        .tint(.indigo)
}

#Preview("Button Dark") {
    RegistryButtonStylePreview()
        .tint(.indigo)
        .preferredColorScheme(.dark)
}

#Preview("Button Right to Left") {
    RegistryButtonStylePreview()
        .tint(.indigo)
        .environment(\.layoutDirection, .rightToLeft)
}

#Preview("Button Accessibility Size") {
    RegistryButtonStylePreview()
        .tint(.indigo)
        .dynamicTypeSize(.accessibility3)
}
