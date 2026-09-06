import SwiftUI

extension View {
    /// The registry's empty-state surface, rewritten by hand.
    func handmadeEmptyState() -> some View {
        modifier(HandmadeEmptyStateModifier())
    }
}

private struct HandmadeEmptyStateModifier: ViewModifier {
    @Environment(\.handmadeTheme) private var theme

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding(theme.metrics.standardSpacing)
            .handmadeSurface()
    }
}
