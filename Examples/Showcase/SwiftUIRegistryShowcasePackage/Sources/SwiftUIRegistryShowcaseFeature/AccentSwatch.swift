import SwiftUI
import SwiftUIRegistryFoundations

/// One accent as a tappable circle. The visible circle can be small; the hit
/// area never drops below the registry minimum.
struct AccentSwatch: View {
    let accent: ThemeTuning.Accent
    let isSelected: Bool
    let custom: ThemeTuning.RGB
    let diameter: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(accent.color(custom: custom) ?? Color.accentColor)
                if accent == .system {
                    Image(systemName: "iphone")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                }
                if isSelected {
                    Circle()
                        .strokeBorder(.primary, lineWidth: 2)
                        .padding(-3)
                }
            }
            .frame(width: diameter, height: diameter)
            .frame(minWidth: RegistryMetrics.minimumHitSize, minHeight: RegistryMetrics.minimumHitSize)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accent.title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
