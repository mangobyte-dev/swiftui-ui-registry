import SwiftUI
import SwiftUIRegistryFoundations

/// The theme preview wall: shadcn's create-page preview recreated as a wall of
/// realistic product cards, so a theme can be judged against a screen of real
/// UI rather than one strip. The cards are a single ordered list in one place;
/// later slices append to it. The wall lays out one column on a compact width
/// and an adaptive, top-aligned grid on a regular width. It owns no
/// `ScrollView`, navigation container, or maximum width: the app decides those.
public struct PreviewWall: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.registryTheme) private var theme

    public init() {}

    public var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: theme.metrics.standardSpacing) {
            ActivateAgentDialog()
            AnalyticsCard()
            AnomalyAlert()
            AssignIssue()
        }
    }

    private var columns: [GridItem] {
        if sizeClass == .regular {
            return [GridItem(.adaptive(minimum: 340, maximum: 460), spacing: theme.metrics.standardSpacing, alignment: .top)]
        }
        return [GridItem(.flexible(), alignment: .top)]
    }
}

#if DEBUG
private struct PreviewWallPreview: View {
    var body: some View {
        ScrollView { PreviewWall().padding() }
    }
}

#Preview("Preview Wall") {
    PreviewWallPreview().registryTheme(.indigo)
}

#Preview("Preview Wall Dark") {
    PreviewWallPreview().registryTheme(.indigo).preferredColorScheme(.dark)
}

#Preview("Preview Wall Right to Left") {
    PreviewWallPreview().registryTheme(.indigo).environment(\.layoutDirection, .rightToLeft)
}

#Preview("Preview Wall Accessibility Size") {
    PreviewWallPreview().registryTheme(.indigo).dynamicTypeSize(.accessibility3)
}
#endif
