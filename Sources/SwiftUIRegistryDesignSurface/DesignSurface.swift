#if canImport(UIKit)
import Sharing
import SwiftUI
import SwiftUIRegistryFoundations

public extension View {
    /// Turns this subtree into a design surface in debug builds: the theme the
    /// shared tokens describe is applied here, the tuning panel stays beside the
    /// content (a trailing column at regular width, a sheet the content remains
    /// interactive under at compact width), and a floating Tune button opens
    /// it. Every registry item below reads the tuned tokens from the environment
    /// and updates as a knob moves; the tokens persist in `design-tokens.json`
    /// (``ThemeTuning/fileURL``) and leave through the panel's copy actions.
    ///
    /// A release build returns the content unchanged. Apply it inside the
    /// app's own `registryTheme(_:)`, `ContentView().designSurface().registryTheme(.app)`,
    /// so the tuned theme is the nearer one while tuning and the app's theme is
    /// the only one shipped.
    func designSurface() -> some View {
        #if DEBUG
        modifier(DesignSurfaceModifier(isPresented: nil, presetsFooter: EmptyView()))
        #else
        self
        #endif
    }

    /// The surface with the host owning the panel's trigger through `isPresented`
    /// instead of the floating button.
    func designSurface(isPresented: Binding<Bool>) -> some View {
        #if DEBUG
        modifier(DesignSurfaceModifier(isPresented: isPresented, presetsFooter: EmptyView()))
        #else
        self
        #endif
    }

    /// The surface with the host owning the trigger and adding its own row
    /// under the panel's preset chips, such as a link to a sample design system.
    func designSurface<PresetsFooter: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder presetsFooter: () -> PresetsFooter
    ) -> some View {
        #if DEBUG
        modifier(DesignSurfaceModifier(isPresented: isPresented, presetsFooter: presetsFooter()))
        #else
        self
        #endif
    }
}

#if DEBUG
/// The panel is a plain sibling in an `HStack` at regular width, not
/// `inspector(isPresented:)`: measured in the Showcase on iOS 27, that
/// modifier on a tab's navigation stack stopped the auth form's Return key
/// from moving focus even while nothing was presented.
private struct DesignSurfaceModifier<PresetsFooter: View>: ViewModifier {
    let isPresented: Binding<Bool>?
    let presetsFooter: PresetsFooter
    @Shared(.designTokens) private var tuning
    @State private var isPresentedLocally = false
    @State private var selection = ItemSelection()
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var presented: Binding<Bool> {
        isPresented ?? $isPresentedLocally
    }

    func body(content: Content) -> some View {
        HStack(spacing: 0) {
            content
                // Items report their frames and draw their selection ring only
                // while the panel is up; one capture layer above the content
                // resolves a tap to the innermost item so items never compete
                // for the gesture and controls stay untouched when not selecting.
                .environment(
                    \.registryItemSurface,
                    presented.wrappedValue ? RegistryItemSurface(selected: selection.item) : nil
                )
                .overlayPreferenceValue(RegistryItemAnchorsKey.self) { anchors in
                    if selection.isSelecting {
                        GeometryReader { proxy in
                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture(coordinateSpace: .local) { point in
                                    let frames = anchors.map { (name: $0.name, frame: proxy[$0.bounds]) }
                                    withAnimation(.snappy) {
                                        selection.item = ItemSelection.pick(frames, at: point)
                                        selection.isSelecting = false
                                    }
                                }
                                .accessibilityLabel("Tap a registry item to select it")
                                .accessibilityAddTraits(.isButton)
                        }
                    }
                }
            if sizeClass == .regular && presented.wrappedValue {
                Divider()
                panel
                    .frame(width: 380)
                    .transition(.move(edge: .trailing))
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if isPresented == nil {
                Button("Tune", systemImage: "slider.horizontal.3") {
                    withAnimation(.snappy) { presented.wrappedValue.toggle() }
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
        .sheet(isPresented: sizeClass == .compact ? presented : .constant(false)) {
            panel
                .presentationDetents([.medium, .large])
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
        }
        .registryTheme(tuning.theme)
        .preferredColorScheme(tuning.preferredColorScheme)
        .transformEnvironment(\.layoutDirection) { direction in
            if tuning.rightToLeft { direction = .rightToLeft }
        }
        .transformEnvironment(\.dynamicTypeSize) { size in
            if let tuned = tuning.dynamicTypeSize { size = tuned }
        }
    }

    private var panel: some View {
        TuningPanel(tuning: Binding($tuning), selection: $selection) { presetsFooter }
    }
}
#endif
#endif
