import SwiftUI

extension View {
    /// The registry's separator color and insets on a native `Divider`, rewritten by hand.
    func handmadeSeparator(insets: EdgeInsets = EdgeInsets()) -> some View {
        modifier(HandmadeSeparatorModifier(insets: insets))
    }
}

private struct HandmadeSeparatorModifier: ViewModifier {
    @Environment(\.handmadeTheme) private var theme

    let insets: EdgeInsets

    func body(content: Content) -> some View {
        content
            .overlay(theme.border)
            .frame(maxWidth: .infinity)
            .padding(.top, insets.top)
            .padding(.leading, insets.leading)
            .padding(.bottom, insets.bottom)
            .padding(.trailing, insets.trailing)
    }
}
