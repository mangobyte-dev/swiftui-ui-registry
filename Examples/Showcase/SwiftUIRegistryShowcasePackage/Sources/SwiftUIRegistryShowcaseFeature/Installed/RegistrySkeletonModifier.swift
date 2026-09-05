import Foundation
import SwiftUI
import SwiftUIRegistryFoundations

public extension View {
    /// Turns the receiver into a loading placeholder: native redaction, no
    /// interaction, one accessibility element with a loading label, and a
    /// gentle pulse that stops under Reduce Motion. Pass `false` to render the
    /// real content unchanged, so the same view tree serves both states.
    func registrySkeleton(
        _ isActive: Bool = true,
        accessibilityLabel: LocalizedStringResource = "Loading"
    ) -> some View {
        modifier(
            RegistrySkeletonModifier(
                isActive: isActive,
                accessibilityLabel: accessibilityLabel
            )
        )
    }
}

private struct RegistrySkeletonModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let isActive: Bool
    let accessibilityLabel: LocalizedStringResource

    @ViewBuilder
    func body(content: Content) -> some View {
        if isActive {
            placeholder(content)
                .disabled(true)
                .allowsHitTesting(false)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(accessibilityLabel))
        } else {
            content
        }
    }

    @ViewBuilder
    private func placeholder(_ content: Content) -> some View {
        let redacted = content.redacted(reason: .placeholder)
        if reduceMotion {
            redacted.opacity(0.7)
        } else {
            redacted.phaseAnimator([1.0, 0.45]) { view, phase in
                view.opacity(phase)
            } animation: { _ in
                .easeInOut(duration: 0.9)
            }
        }
    }
}

private struct RegistrySkeletonModifierPreview: View {
    @Environment(\.registryTheme) private var theme
    var isLoading = true

    var body: some View {
        VStack(alignment: .leading, spacing: theme.metrics.standardSpacing) {
            ForEach(0..<3, id: \.self) { index in
                HStack(spacing: theme.metrics.standardSpacing) {
                    Circle()
                        .fill(theme.surface)
                        .frame(width: 40, height: 40)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Mishmash Bakery order \(index + 1)")
                            .font(.body.weight(.medium))
                        Text("Placeholder detail text")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Open") {}
                        .buttonStyle(.bordered)
                }
            }
        }
        .registrySkeleton(isLoading)
        .padding()
    }
}

#Preview("Skeleton") {
    RegistrySkeletonModifierPreview()
}

#Preview("Skeleton Loaded") {
    RegistrySkeletonModifierPreview(isLoading: false)
}

#Preview("Skeleton Dark") {
    RegistrySkeletonModifierPreview().preferredColorScheme(.dark)
}

#Preview("Skeleton Accessibility Size") {
    RegistrySkeletonModifierPreview().dynamicTypeSize(.accessibility3)
}
