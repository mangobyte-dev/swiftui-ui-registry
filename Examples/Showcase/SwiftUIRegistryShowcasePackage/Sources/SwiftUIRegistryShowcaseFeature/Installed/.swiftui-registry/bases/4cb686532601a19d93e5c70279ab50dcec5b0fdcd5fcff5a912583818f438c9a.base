import SwiftUI

/// Explicitly retains the platform switch treatment for a native SwiftUI `Toggle`.
public struct RegistrySwitchToggleStyle: ToggleStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        Toggle(configuration)
            .toggleStyle(.switch)
    }
}

public extension ToggleStyle where Self == RegistrySwitchToggleStyle {
    static var registrySwitch: RegistrySwitchToggleStyle { RegistrySwitchToggleStyle() }
}

private struct RegistrySwitchToggleStylePreview: View {
    @State private var notifications = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Notifications", isOn: $notifications)
            Toggle("Unavailable setting", isOn: .constant(false))
                .disabled(true)
        }
        .toggleStyle(.registrySwitch)
        .padding()
    }
}

#Preview("Switch") {
    RegistrySwitchToggleStylePreview().tint(.indigo)
}

#Preview("Switch Dark") {
    RegistrySwitchToggleStylePreview().tint(.indigo).preferredColorScheme(.dark)
}

#Preview("Switch Right to Left") {
    RegistrySwitchToggleStylePreview().tint(.indigo).environment(\.layoutDirection, .rightToLeft)
}

#Preview("Switch Accessibility Size") {
    RegistrySwitchToggleStylePreview().tint(.indigo).dynamicTypeSize(.accessibility3)
}
