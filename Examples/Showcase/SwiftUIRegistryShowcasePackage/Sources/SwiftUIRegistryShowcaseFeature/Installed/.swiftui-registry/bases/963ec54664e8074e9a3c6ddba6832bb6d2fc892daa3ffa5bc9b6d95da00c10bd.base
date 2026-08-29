import SwiftUI

public extension View {
    /// Presents a native `Picker` as an inline, mutually exclusive option group.
    func registryRadioGroup() -> some View {
        modifier(RegistryRadioGroupModifier())
    }
}

private struct RegistryRadioGroupModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.pickerStyle(.inline)
    }
}

private struct RegistryRadioGroupModifierPreview: View {
    @State private var selection = "standard"

    var body: some View {
        Picker("Delivery speed", selection: $selection) {
            Text("Standard").tag("standard")
            Text("Express").tag("express")
            Text("Same day").tag("same-day")
        }
        .registryRadioGroup()
        .padding()
    }
}

#Preview("Radio Group") {
    RegistryRadioGroupModifierPreview().tint(.indigo)
}

#Preview("Radio Group Dark") {
    RegistryRadioGroupModifierPreview().tint(.indigo).preferredColorScheme(.dark)
}

#Preview("Radio Group Right to Left") {
    RegistryRadioGroupModifierPreview().tint(.indigo).environment(\.layoutDirection, .rightToLeft)
}

#Preview("Radio Group Accessibility Size") {
    RegistryRadioGroupModifierPreview().tint(.indigo).dynamicTypeSize(.accessibility3)
}
