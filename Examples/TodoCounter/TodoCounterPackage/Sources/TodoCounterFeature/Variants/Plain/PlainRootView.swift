import ComposableArchitecture
import SwiftUI

/// The plain layer: the same screens on stock SwiftUI controls with no styling at all.
struct PlainRootView: View {
    let store: StoreOf<TodoCounter>

    var body: some View {
        TabView {
            Tab("Todos", systemImage: "checklist") {
                NavigationStack {
                    PlainTodosView(store: store.scope(state: \.todos, action: \.todos))
                }
            }
            Tab("Counter", systemImage: "number") {
                NavigationStack {
                    PlainCounterView(store: store.scope(state: \.counter, action: \.counter))
                }
            }
        }
    }
}
