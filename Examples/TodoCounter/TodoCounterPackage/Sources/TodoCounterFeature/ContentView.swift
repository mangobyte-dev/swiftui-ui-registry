import ComposableArchitecture
import Foundation
import SwiftUI

/// The three UI layers over the same reducers: the registry items this app owns (the
/// default), stock SwiftUI with no styling (`-ui plain`), and the same design written by
/// hand without the registry (`-ui handmade`). The comparison in the README measures them.
public enum UIVariant: String, CaseIterable, Sendable {
    case registry
    case plain
    case handmade

    /// The variant named by the `-ui` launch argument, or the registry layer.
    public static var launched: UIVariant {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-ui"), index + 1 < arguments.count,
              let variant = UIVariant(rawValue: arguments[index + 1])
        else { return .registry }
        return variant
    }
}

public struct ContentView: View {
    /// One store for the process; the app hands it in once at launch.
    @MainActor public static let liveStore = Store(initialState: TodoCounter.State()) {
        TodoCounter()
    }

    let store: StoreOf<TodoCounter>
    let variant: UIVariant

    public init(store: StoreOf<TodoCounter>, variant: UIVariant = .launched) {
        self.store = store
        self.variant = variant
    }

    public var body: some View {
        switch variant {
        case .registry: RegistryRootView(store: store)
        case .plain: PlainRootView(store: store)
        case .handmade: HandmadeRootView(store: store)
        }
    }
}
