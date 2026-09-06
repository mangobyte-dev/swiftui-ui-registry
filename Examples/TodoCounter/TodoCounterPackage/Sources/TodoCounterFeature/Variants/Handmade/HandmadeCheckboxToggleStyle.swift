import SwiftUI

/// The registry's checkbox for a native `Toggle`, rewritten by hand: a button that flips
/// the binding, a box that scales with the text, and a switch as its accessibility
/// representation so assistive technology keeps the toggle semantics.
struct HandmadeCheckboxToggleStyle: ToggleStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.handmadeTheme) private var theme
    @ScaledMetric(relativeTo: .body) private var boxSize: CGFloat = 22

    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: theme.metrics.compactSpacing) {
                checkbox(configuration: configuration)
                configuration.label
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minHeight: HandmadeMetrics.minimumHitSize)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : theme.disabledOpacity)
        .accessibilityRepresentation {
            Toggle(configuration)
                .toggleStyle(.switch)
        }
    }

    private func checkbox(configuration: Configuration) -> some View {
        let isSelected = configuration.isOn || configuration.isMixed
        let shape = RoundedRectangle(cornerRadius: theme.metrics.compactRadius, style: .continuous)

        return Image(systemName: configuration.isMixed ? "minus" : "checkmark")
            .font(.caption2.weight(.bold))
            .foregroundStyle(.tint)
            .opacity(isSelected ? 1 : 0)
            .frame(width: boxSize, height: boxSize)
            .background(TintShapeStyle().opacity(isSelected ? 0.16 : 0), in: shape)
            .overlay {
                shape.stroke(
                    isSelected ? AnyShapeStyle(TintShapeStyle()) : AnyShapeStyle(theme.border),
                    lineWidth: theme.metrics.borderWidth
                )
            }
            .accessibilityHidden(true)
    }
}

extension ToggleStyle where Self == HandmadeCheckboxToggleStyle {
    static var handmadeCheckbox: HandmadeCheckboxToggleStyle { HandmadeCheckboxToggleStyle() }
}
