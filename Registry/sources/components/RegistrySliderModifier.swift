import SwiftUI

public extension View {
    /// Applies optional semantic tint and control sizing to a native `Slider`.
    func registrySlider(
        tint: Color? = nil,
        controlSize: ControlSize? = nil
    ) -> some View {
        modifier(RegistrySliderModifier(tint: tint, controlSize: controlSize))
    }
}

private struct RegistrySliderModifier: ViewModifier {
    @Environment(\.controlSize) private var inheritedControlSize

    let tint: Color?
    let controlSize: ControlSize?

    @ViewBuilder
    func body(content: Content) -> some View {
        if let tint {
            content
                .tint(tint)
                .controlSize(controlSize ?? inheritedControlSize)
        } else {
            content.controlSize(controlSize ?? inheritedControlSize)
        }
    }
}

private struct RegistrySliderModifierPreview: View {
    @State private var volume = 64.0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Volume")
                Spacer()
                Text(volume / 100, format: .percent.precision(.fractionLength(0)))
                    .monospacedDigit()
            }

            Slider(value: $volume, in: 0...100, step: 1) {
                Text("Volume")
            } minimumValueLabel: {
                Image(systemName: "speaker.fill")
                    .accessibilityHidden(true)
            } maximumValueLabel: {
                Image(systemName: "speaker.wave.3.fill")
                    .accessibilityHidden(true)
            }
            .registrySlider()
            .controlSize(.large)
        }
        .padding()
    }
}

#Preview("Slider") {
    RegistrySliderModifierPreview().tint(.indigo)
}

#Preview("Slider Dark") {
    RegistrySliderModifierPreview().tint(.indigo).preferredColorScheme(.dark)
}

#Preview("Slider Right to Left") {
    RegistrySliderModifierPreview().tint(.indigo).environment(\.layoutDirection, .rightToLeft)
}

#Preview("Slider Accessibility Size") {
    RegistrySliderModifierPreview().tint(.indigo).dynamicTypeSize(.accessibility3)
}
