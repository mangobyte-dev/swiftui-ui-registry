import SwiftUI

public extension View {
    /// Presents a native local-selection `Picker` as segmented tabs.
    func registryTabs() -> some View {
        modifier(RegistryTabsModifier())
    }
}

private struct RegistryTabsModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.pickerStyle(.segmented)
    }
}

private struct RegistryTabsModifierPreview: View {
    @State private var selection = "overview"

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Section", selection: $selection) {
                Text("Overview").tag("overview")
                Text("Activity").tag("activity")
                Text("Settings").tag("settings")
            }
            .registryTabs()

            Text(selection.capitalized)
                .frame(maxWidth: .infinity, minHeight: 80)
        }
        .padding()
    }
}

#Preview("Tabs") {
    RegistryTabsModifierPreview().tint(.indigo)
}

#Preview("Tabs Dark") {
    RegistryTabsModifierPreview().tint(.indigo).preferredColorScheme(.dark)
}

#Preview("Tabs Right to Left") {
    RegistryTabsModifierPreview().tint(.indigo).environment(\.layoutDirection, .rightToLeft)
}

#Preview("Tabs Accessibility Size") {
    RegistryTabsModifierPreview().tint(.indigo).dynamicTypeSize(.accessibility3)
}
