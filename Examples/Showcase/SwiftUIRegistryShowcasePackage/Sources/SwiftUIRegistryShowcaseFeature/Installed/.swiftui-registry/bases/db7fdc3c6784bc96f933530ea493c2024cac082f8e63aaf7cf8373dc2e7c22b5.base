import SwiftUI

/// Applies one registry button treatment to every control in a native `ControlGroup`.
public struct RegistryButtonGroupStyle: ControlGroupStyle {
    private let variant: RegistryButtonStyle.Variant

    public init(_ variant: RegistryButtonStyle.Variant = .secondary) {
        self.variant = variant
    }

    public func makeBody(configuration: Configuration) -> some View {
        ControlGroup(configuration)
            .buttonStyle(RegistryButtonStyle(variant))
    }
}

public extension ControlGroupStyle where Self == RegistryButtonGroupStyle {
    static var registryButtons: RegistryButtonGroupStyle {
        RegistryButtonGroupStyle()
    }
}

private struct RegistryButtonGroupStylePreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ControlGroup("Editor actions") {
                Button("Undo", systemImage: "arrow.uturn.backward") {}
                Button("Redo", systemImage: "arrow.uturn.forward") {}
                Button("Share", systemImage: "square.and.arrow.up") {}
            }
            .labelStyle(.iconOnly)
            .controlGroupStyle(.registryButtons)

            ControlGroup("Document actions") {
                Button("Save") {}
                Button("Duplicate") {}
                Button("Delete", role: .destructive) {}
            }
            .controlGroupStyle(RegistryButtonGroupStyle(.outline))
        }
        .padding()
    }
}

#Preview("Button Group") {
    RegistryButtonGroupStylePreview()
        .tint(.indigo)
}

#Preview("Button Group Dark") {
    RegistryButtonGroupStylePreview()
        .tint(.indigo)
        .preferredColorScheme(.dark)
}

#Preview("Button Group Right to Left") {
    RegistryButtonGroupStylePreview()
        .tint(.indigo)
        .environment(\.layoutDirection, .rightToLeft)
}

#Preview("Button Group Accessibility Size") {
    RegistryButtonGroupStylePreview()
        .tint(.indigo)
        .dynamicTypeSize(.accessibility3)
}
