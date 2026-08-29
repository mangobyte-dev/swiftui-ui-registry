import SwiftUI
import SwiftUIRegistryFoundations

/// A checkbox treatment for a native SwiftUI `Toggle` binding and label.
public struct RegistryCheckboxToggleStyle: ToggleStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.registryTheme) private var theme

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: theme.metrics.compactSpacing) {
                checkbox(configuration: configuration)
                configuration.label
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .contentShape(Rectangle())
            .frame(minHeight: 44)
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : 0.5)
        .accessibilityRepresentation {
            Toggle(configuration)
                .toggleStyle(.switch)
        }
    }

    private func checkbox(configuration: Configuration) -> some View {
        let isSelected = configuration.isOn || configuration.isMixed
        let shape = RoundedRectangle(cornerRadius: 5, style: .continuous)

        return Image(systemName: configuration.isMixed ? "minus" : "checkmark")
            .font(.caption2.weight(.bold))
            .foregroundStyle(.tint)
            .opacity(isSelected ? 1 : 0)
            .frame(width: 22, height: 22)
            .background(
                isSelected
                    ? AnyShapeStyle(TintShapeStyle().opacity(0.16))
                    : AnyShapeStyle(Color.clear),
                in: shape
            )
            .overlay {
                shape.stroke(
                    isSelected ? AnyShapeStyle(TintShapeStyle()) : AnyShapeStyle(theme.border),
                    lineWidth: 1
                )
            }
            .accessibilityHidden(true)
    }
}

public extension ToggleStyle where Self == RegistryCheckboxToggleStyle {
    static var registryCheckbox: RegistryCheckboxToggleStyle { RegistryCheckboxToggleStyle() }
}

private struct RegistryCheckboxToggleStylePreview: View {
    @State private var accepted = true
    @State private var updates = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Accept terms", isOn: $accepted)
            Toggle("Product updates", isOn: $updates)
            Toggle("Unavailable option", isOn: .constant(false))
                .disabled(true)
        }
        .toggleStyle(.registryCheckbox)
        .padding()
    }
}

#Preview("Checkbox") {
    RegistryCheckboxToggleStylePreview().tint(.indigo)
}

#Preview("Checkbox Dark") {
    RegistryCheckboxToggleStylePreview().tint(.indigo).preferredColorScheme(.dark)
}

#Preview("Checkbox Right to Left") {
    RegistryCheckboxToggleStylePreview().tint(.indigo).environment(\.layoutDirection, .rightToLeft)
}

#Preview("Checkbox Accessibility Size") {
    RegistryCheckboxToggleStylePreview().tint(.indigo).dynamicTypeSize(.accessibility3)
}
