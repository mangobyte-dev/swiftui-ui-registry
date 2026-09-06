import SwiftUI

/// The registry's card surface for a native `GroupBox`, rewritten by hand.
struct HandmadeCardStyle: GroupBoxStyle {
    @Environment(\.handmadeTheme) private var theme

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: theme.metrics.standardSpacing) {
            configuration.label
                .font(.headline)
            configuration.content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.metrics.standardSpacing)
        .handmadeSurface()
    }
}

extension GroupBoxStyle where Self == HandmadeCardStyle {
    static var handmadeCard: HandmadeCardStyle { HandmadeCardStyle() }
}
