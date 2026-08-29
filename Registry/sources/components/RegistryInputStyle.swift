import SwiftUI
import SwiftUIRegistryFoundations

/// A bordered input treatment for native `TextField` and `SecureField` controls.
public struct RegistryInputStyle: TextFieldStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.registryTheme) private var theme

    private let isInvalid: Bool

    public init(isInvalid: Bool = false) {
        self.isInvalid = isInvalid
    }

    public func _body(configuration: TextField<Self._Label>) -> some View {
        let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)

        configuration
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
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

public extension TextFieldStyle where Self == RegistryInputStyle {
    static var registryInput: RegistryInputStyle { RegistryInputStyle() }
}

private struct RegistryInputStylePreview: View {
    @State private var name = ""
    @State private var email = "not-an-email"
    @State private var password = ""
    @FocusState private var focusedField: Field?

    private enum Field {
        case name
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Full name", text: $name)
                .textFieldStyle(.registryInput)
                .focused($focusedField, equals: .name)

            SecureField("Password", text: $password)
                .textFieldStyle(.registryInput)

            VStack(alignment: .leading, spacing: 4) {
                TextField("Email", text: $email)
                    .textFieldStyle(RegistryInputStyle(isInvalid: true))
                    .accessibilityHint("Enter a valid email address")
                Text("Enter a valid email address")
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            TextField("Disabled", text: .constant("Unavailable"))
                .textFieldStyle(.registryInput)
                .disabled(true)
        }
        .padding()
        .onAppear { focusedField = .name }
    }
}

#Preview("Input States") {
    RegistryInputStylePreview().tint(.indigo)
}

#Preview("Input Dark") {
    RegistryInputStylePreview().tint(.indigo).preferredColorScheme(.dark)
}

#Preview("Input Right to Left") {
    RegistryInputStylePreview().tint(.indigo).environment(\.layoutDirection, .rightToLeft)
}

#Preview("Input Accessibility Size") {
    RegistryInputStylePreview().tint(.indigo).dynamicTypeSize(.accessibility3)
}
