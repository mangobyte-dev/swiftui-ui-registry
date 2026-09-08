#if canImport(UIKit)
import SwiftUI

/// The surface's tool state, shared between the app window (where the items
/// live and report their frames) and the overlay window (where the button and
/// the panel live): whether the panel is up, which item is selected, and the
/// host's optional row under the preset chips.
@MainActor
@Observable
final class DesignSurfaceState {
    static let shared = DesignSurfaceState()

    var isPresented = false
    /// True when the host drives `isPresented` itself (the Showcase's accessory
    /// strip); the window then shows no floating button of its own.
    var hostOwnsTrigger = false
    var selection = ItemSelection()
    /// The host's row under the preset chips, erased because the overlay's
    /// root is not generic over the host.
    var presetsFooter: AnyView?

    private init() {}
}
#endif
