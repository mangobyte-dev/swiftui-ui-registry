import SwiftUI

public extension View {
    /// Retains the minimal platform menu treatment for a native `Picker`.
    func registryNativeSelect() -> some View {
        modifier(RegistryNativeSelectModifier())
    }
}

private struct RegistryNativeSelectModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.pickerStyle(.menu)
    }
}

private struct RegistryNativeSelectModifierPreview: View {
    @State private var sort = "recent"

    var body: some View {
        Picker("Sort", selection: $sort) {
            Text("Most recent").tag("recent")
            Text("Oldest").tag("oldest")
            Text("Amount").tag("amount")
        }
        .registryNativeSelect()
        .padding()
    }
}

#Preview("Native Select") {
    RegistryNativeSelectModifierPreview().tint(.indigo)
}

#Preview("Native Select Dark") {
    RegistryNativeSelectModifierPreview().tint(.indigo).preferredColorScheme(.dark)
}

#Preview("Native Select Right to Left") {
    RegistryNativeSelectModifierPreview().tint(.indigo).environment(\.layoutDirection, .rightToLeft)
}

#Preview("Native Select Accessibility Size") {
    RegistryNativeSelectModifierPreview().tint(.indigo).dynamicTypeSize(.accessibility3)
}
