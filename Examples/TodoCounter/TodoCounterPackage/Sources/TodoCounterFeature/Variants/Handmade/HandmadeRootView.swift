import ComposableArchitecture
import SwiftUI

/// The handmade layer: the registry variant's design, every style written in this app.
struct HandmadeRootView: View {
    let store: StoreOf<TodoCounter>

    var body: some View {
        TabView {
            Tab("Todos", systemImage: "checklist") {
                NavigationStack {
                    HandmadeTodosView(store: store.scope(state: \.todos, action: \.todos))
                }
            }
            Tab("Counter", systemImage: "number") {
                NavigationStack {
                    HandmadeCounterView(store: store.scope(state: \.counter, action: \.counter))
                }
            }
        }
        .handmadeTheme(.app)
        .fontDesign(.rounded)
    }
}
