import SwiftUI
import SwiftUIRegistryFoundations

public extension View {
    /// Applies input-matching chrome to a native `TextEditor`.
    func registryTextArea(
        isInvalid: Bool = false,
        minimumHeight: CGFloat = 120
    ) -> some View {
        modifier(RegistryTextAreaModifier(isInvalid: isInvalid, minimumHeight: minimumHeight))
    }
}

private struct RegistryTextAreaModifier: ViewModifier {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.registryTheme) private var theme

    let isInvalid: Bool
    let minimumHeight: CGFloat

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)

        content
            .scrollContentBackground(.hidden)
            .padding(8)
            .frame(minHeight: minimumHeight, alignment: .topLeading)
            .background(theme.surface, in: shape)
            .overlay {
                shape.stroke(borderStyle, lineWidth: isFocused || isInvalid ? 2 : 1)
            }
            .opacity(isEnabled ? 1 : 0.5)
    }

    private var borderStyle: AnyShapeStyle {
        if isInvalid {
            AnyShapeStyle(theme.negative)
        } else if isFocused {
            AnyShapeStyle(TintShapeStyle())
        } else {
            AnyShapeStyle(theme.border)
        }
    }
}

private struct RegistryTextAreaModifierPreview: View {
    @State private var notes = "Add delivery instructions"
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextEditor(text: $notes)
                .registryTextArea()
                .focused($isFocused)
                .accessibilityLabel("Delivery instructions")

            VStack(alignment: .leading, spacing: 4) {
                TextEditor(text: .constant("Too short"))
                    .registryTextArea(isInvalid: true, minimumHeight: 80)
                    .accessibilityLabel("Request details")
                    .accessibilityHint("Enter at least 20 characters")
                Text("Enter at least 20 characters")
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .onAppear { isFocused = true }
    }
}

#Preview("Textarea States") {
    RegistryTextAreaModifierPreview().tint(.indigo)
}

#Preview("Textarea Dark") {
    RegistryTextAreaModifierPreview().tint(.indigo).preferredColorScheme(.dark)
}

#Preview("Textarea Right to Left") {
    RegistryTextAreaModifierPreview().tint(.indigo).environment(\.layoutDirection, .rightToLeft)
}

#Preview("Textarea Accessibility Size") {
    RegistryTextAreaModifierPreview().tint(.indigo).dynamicTypeSize(.accessibility3)
}
