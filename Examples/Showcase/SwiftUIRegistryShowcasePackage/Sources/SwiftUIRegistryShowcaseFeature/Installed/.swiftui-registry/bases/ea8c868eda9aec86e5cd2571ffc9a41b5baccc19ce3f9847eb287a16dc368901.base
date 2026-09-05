import Foundation
import SwiftUI
import SwiftUIRegistryFoundations

/// The message semantics of an ``InlineAlert``. Each variant pairs a symbol
/// with its color so the meaning never rests on color alone.
public enum InlineAlertVariant: Sendable {
    case informational
    case positive
    case destructive
}

/// An inline, non-modal message that stays in the content flow. System `.alert`
/// remains the choice for interrupting decisions; this is for status the user
/// can read past, such as a delayed delivery or a completed import.
public struct InlineAlert<Actions: View>: View {
    @Environment(\.registryTheme) private var theme

    private let title: LocalizedStringResource
    private let message: Text?
    private let variant: InlineAlertVariant
    private let systemImage: String?
    private let actions: Actions

    /// - Parameters:
    ///   - title: The headline, always visible.
    ///   - message: Optional supporting copy prepared by the caller.
    ///   - variant: Semantic tone; defaults to informational.
    ///   - systemImage: Overrides the variant's default symbol.
    ///   - actions: Optional caller-owned buttons rendered under the copy.
    public init(
        _ title: LocalizedStringResource,
        message: Text? = nil,
        variant: InlineAlertVariant = .informational,
        systemImage: String? = nil,
        @ViewBuilder actions: () -> Actions
    ) {
        self.title = title
        self.message = message
        self.variant = variant
        self.systemImage = systemImage
        self.actions = actions()
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: theme.metrics.controlRadius, style: .continuous)

        HStack(alignment: .top, spacing: theme.metrics.compactSpacing) {
            Image(systemName: systemImage ?? defaultSystemImage)
                .font(.body.weight(.semibold))
                .foregroundStyle(toneStyle)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.metrics.compactSpacing / 2) {
                VStack(alignment: .leading, spacing: theme.metrics.compactSpacing / 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                    if let message {
                        message
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .accessibilityElement(children: .combine)

                actions
                    .controlSize(.small)
                    .padding(.top, theme.metrics.compactSpacing / 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(theme.metrics.standardSpacing)
        .background(backgroundStyle, in: shape)
        .overlay {
            shape.stroke(borderStyle, lineWidth: theme.metrics.borderWidth)
        }
    }

    private var defaultSystemImage: String {
        switch variant {
        case .informational: "info.circle.fill"
        case .positive: "checkmark.circle.fill"
        case .destructive: "exclamationmark.triangle.fill"
        }
    }

    private var toneStyle: AnyShapeStyle {
        switch variant {
        case .informational: AnyShapeStyle(TintShapeStyle())
        case .positive: AnyShapeStyle(theme.positive)
        case .destructive: AnyShapeStyle(theme.negative)
        }
    }

    private var backgroundStyle: AnyShapeStyle {
        switch variant {
        case .informational: AnyShapeStyle(theme.surface)
        case .positive: AnyShapeStyle(theme.positive.opacity(0.1))
        case .destructive: AnyShapeStyle(theme.negative.opacity(0.1))
        }
    }

    private var borderStyle: AnyShapeStyle {
        switch variant {
        case .informational: AnyShapeStyle(theme.border)
        case .positive: AnyShapeStyle(theme.positive.opacity(0.35))
        case .destructive: AnyShapeStyle(theme.negative.opacity(0.35))
        }
    }
}

public extension InlineAlert where Actions == EmptyView {
    /// An alert with copy only and no actions.
    init(
        _ title: LocalizedStringResource,
        message: Text? = nil,
        variant: InlineAlertVariant = .informational,
        systemImage: String? = nil
    ) {
        self.init(
            title,
            message: message,
            variant: variant,
            systemImage: systemImage,
            actions: { EmptyView() }
        )
    }
}

private struct InlineAlertPreview: View {
    var body: some View {
        VStack(spacing: 16) {
            InlineAlert(
                "Card delivery delayed",
                message: Text("Your new card now arrives on Thursday.")
            )

            InlineAlert(
                "Import complete",
                message: Text("124 transactions were added."),
                variant: .positive
            )

            InlineAlert(
                "Payment failed",
                message: Text("The card on file was declined."),
                variant: .destructive
            ) {
                HStack {
                    Button("Retry") {}
                        .buttonStyle(.registry)
                    Button("Change card") {}
                        .buttonStyle(.registryOutline)
                }
            }
        }
        .padding()
    }
}

#Preview("Inline Alert") {
    InlineAlertPreview().tint(.indigo)
}

#Preview("Inline Alert Dark") {
    InlineAlertPreview().tint(.indigo).preferredColorScheme(.dark)
}

#Preview("Inline Alert Right to Left") {
    InlineAlertPreview().tint(.indigo).environment(\.layoutDirection, .rightToLeft)
}

#Preview("Inline Alert Accessibility Size") {
    InlineAlertPreview().tint(.indigo).dynamicTypeSize(.accessibility3)
}
