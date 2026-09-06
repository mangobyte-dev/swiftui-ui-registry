import ComposableArchitecture
import SwiftUI
import SwiftUIRegistryFoundations

public struct ContentView: View {
    /// One store for the process; the app hands it in once at launch.
    @MainActor public static let liveStore = Store(initialState: TodoCounter.State()) {
        TodoCounter()
    }

    let store: StoreOf<TodoCounter>

    public init(store: StoreOf<TodoCounter>) {
        self.store = store
    }

    public var body: some View {
        TabView {
            Tab("Todos", systemImage: "checklist") {
                NavigationStack {
                    TodosView(store: store.scope(state: \.todos, action: \.todos))
                }
            }
            Tab("Counter", systemImage: "number") {
                NavigationStack {
                    CounterView(store: store.scope(state: \.counter, action: \.counter))
                }
            }
        }
        // Set once at the root: every registry item and tinted native control below inherits
        // the theme that `swiftui-registry preset apply` wrote and this app then customized.
        .registryTheme(.app)
        // App-wide typography, the way a shadcn project overrides its font family.
        .fontDesign(.rounded)
    }
}
