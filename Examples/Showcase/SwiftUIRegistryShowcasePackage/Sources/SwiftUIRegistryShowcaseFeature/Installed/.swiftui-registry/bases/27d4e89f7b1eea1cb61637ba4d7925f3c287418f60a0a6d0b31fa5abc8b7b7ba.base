import SwiftUI
import SwiftUIRegistryFoundations

public extension View {
    /// Draws the receiver as a keycap: monospaced, bordered, one line. For
    /// keyboard shortcut hints next to commands; hidden from accessibility
    /// unless the caller supplies a spoken label, because "⌘K" reads poorly.
    func registryKeycap(accessibilityLabel: Text? = nil) -> some View {
        modifier(RegistryKeycapModifier(accessibilityLabel: accessibilityLabel))
    }
}

private struct RegistryKeycapModifier: ViewModifier {
    @Environment(\.registryTheme) private var theme

    let accessibilityLabel: Text?

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: theme.metrics.compactRadius, style: .continuous)

        content
            .font(.caption.monospaced().weight(.medium))
            .lineLimit(1)
            .fixedSize()
            .foregroundStyle(.secondary)
            .padding(.horizontal, theme.metrics.compactSpacing / 2 + 2)
            .padding(.vertical, 2)
            .background(theme.surface, in: shape)
            .overlay {
                shape.stroke(theme.border, lineWidth: theme.metrics.borderWidth)
            }
            .modifier(KeycapAccessibility(label: accessibilityLabel))
    }
}

private struct KeycapAccessibility: ViewModifier {
    let label: Text?

    @ViewBuilder
    func body(content: Content) -> some View {
        if let label {
            content
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(label)
        } else {
            content.accessibilityHidden(true)
        }
    }
}

private struct RegistryKeycapModifierPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Open search")
                Spacer()
                Text("⌘K").registryKeycap(accessibilityLabel: Text("Command K"))
            }
            HStack {
                Text("Select")
                Spacer()
                Text("↩").registryKeycap(accessibilityLabel: Text("Return"))
            }
            HStack {
                Text("Dismiss")
                Spacer()
                Text("esc").registryKeycap(accessibilityLabel: Text("Escape"))
            }
        }
        .padding()
    }
}

#Preview("Keycap") {
    RegistryKeycapModifierPreview()
}

#Preview("Keycap Dark") {
    RegistryKeycapModifierPreview().preferredColorScheme(.dark)
}

#Preview("Keycap Accessibility Size") {
    RegistryKeycapModifierPreview().dynamicTypeSize(.accessibility3)
}
