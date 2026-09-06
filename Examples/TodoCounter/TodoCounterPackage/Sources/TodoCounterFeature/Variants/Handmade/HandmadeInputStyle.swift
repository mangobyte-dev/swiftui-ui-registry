import SwiftUI

/// The registry's bordered input, rewritten by hand. `TextFieldStyle` exposes only the
/// underscored `_body(configuration:)` requirement, which a developer has to know.
struct HandmadeInputStyle: TextFieldStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.handmadeTheme) private var theme
    @FocusState private var isFocused: Bool

    private let isInvalid: Bool

    init(isInvalid: Bool = false) {
        self.isInvalid = isInvalid
    }

    func _body(configuration: TextField<Self._Label>) -> some View {
        let shape = RoundedRectangle(cornerRadius: theme.metrics.controlRadius, style: .continuous)

        configuration
            .focused($isFocused)
            .padding(.horizontal, theme.metrics.controlHorizontalPadding)
            .padding(.vertical, 10)
            .frame(minHeight: HandmadeMetrics.minimumHitSize)
            .background(theme.surface, in: shape)
            .overlay {
                shape.stroke(
                    borderStyle,
                    lineWidth: isFocused || isInvalid
                        ? theme.metrics.emphasizedBorderWidth
                        : theme.metrics.borderWidth
                )
            }
            .opacity(isEnabled ? 1 : theme.disabledOpacity)
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

extension TextFieldStyle where Self == HandmadeInputStyle {
    static var handmadeInput: HandmadeInputStyle { HandmadeInputStyle() }
}
