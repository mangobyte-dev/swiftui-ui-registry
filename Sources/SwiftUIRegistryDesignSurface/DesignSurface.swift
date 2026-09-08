#if canImport(UIKit)
import Sharing
import SwiftUI
import SwiftUIRegistryFoundations

public extension View {
    /// Turns this subtree into a design surface in debug builds: the theme the
    /// shared tokens describe is applied here, and the tool's own window puts
    /// a draggable Tune button and a floating, movable, resizable panel over
    /// the whole app, which stays live underneath on every tab, sheet, and
    /// cover. Every registry item below reads the tuned tokens from the environment
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

    /// The surface with the host also driving the panel through `isPresented`;
    /// the window's floating button stays.
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
/// The tool lives in its own window (``DesignSurfaceWindow``): this modifier
/// keeps what must sit in the app's tree, the tuned theme and environment
/// switches, the item surface the tagged roots read, and the tap capture
/// that resolves a selection to the innermost item. The button and the
/// floating panel come from the window, so they cover every tab, sheet, and
/// cover while the app stays live underneath.
private struct DesignSurfaceModifier<PresetsFooter: View>: ViewModifier {
    let isPresented: Binding<Bool>?
    let presetsFooter: PresetsFooter
    @Shared(.designTokens) private var tuning
    private let state = DesignSurfaceState.shared

    func body(content: Content) -> some View {
        content
            // Items report their frames and draw their selection ring only
            // while the panel is up; one capture layer above the content
            // resolves a tap to the innermost item so items never compete
            // for the gesture and controls stay untouched when not selecting.
            .environment(
                \.registryItemSurface,
                state.isPresented ? RegistryItemSurface(selected: state.selection.item) : nil
            )
            .overlayPreferenceValue(RegistryItemAnchorsKey.self) { anchors in
                if state.selection.isSelecting {
                    GeometryReader { proxy in
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture(coordinateSpace: .local) { point in
                                let frames = anchors.map { (name: $0.name, frame: proxy[$0.bounds]) }
                                withAnimation(.snappy) {
                                    state.selection.item = ItemSelection.pick(frames, at: point)
                                    state.selection.isSelecting = false
                                }
                            }
                            .accessibilityLabel("Tap a registry item to select it")
                            .accessibilityAddTraits(.isButton)
                    }
                }
            }
            .registryTheme(tuning.theme)
            .preferredColorScheme(tuning.preferredColorScheme)
            .transformEnvironment(\.layoutDirection) { direction in
                if tuning.rightToLeft { direction = .rightToLeft }
            }
            .transformEnvironment(\.dynamicTypeSize) { size in
                if let tuned = tuning.dynamicTypeSize { size = tuned }
            }
            .onAppear {
                if !(presetsFooter is EmptyView) { state.presetsFooter = AnyView(presetsFooter) }
                if let isPresented {
                    state.hostOwnsTrigger = true
                    state.isPresented = isPresented.wrappedValue
                }
                DesignSurfaceWindow.shared.install()
            }
            // The host's binding and the tool's state agree in both directions.
            .onChange(of: isPresented?.wrappedValue) { _, presented in
                if let presented, presented != state.isPresented { state.isPresented = presented }
            }
            .onChange(of: state.isPresented) { _, presented in
                if let isPresented, isPresented.wrappedValue != presented { isPresented.wrappedValue = presented }
            }
    }
}
#endif
#endif
