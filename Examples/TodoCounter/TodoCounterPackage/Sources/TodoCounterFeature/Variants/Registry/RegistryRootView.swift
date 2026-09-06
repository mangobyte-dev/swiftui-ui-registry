import ComposableArchitecture
import SwiftUI
import SwiftUIRegistryFoundations

/// The registry layer: native controls styled by the items this app installed and owns.
struct RegistryRootView: View {
    let store: StoreOf<TodoCounter>

    var body: some View {
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
