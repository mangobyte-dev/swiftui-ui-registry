import ComposableArchitecture
import SwiftUI
import SwiftUIRegistryFoundations

/// Native controls at the call site, registry styles on top, and the store as the only
/// state seam. Nothing here knows how a todo is stored or counted.
struct TodosView: View {
    @Bindable var store: StoreOf<Todos>
    @Environment(\.registryTheme) private var theme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.metrics.sectionSpacing) {
                GroupBox {
                    HStack(spacing: theme.metrics.compactSpacing) {
                        TextField("Add a task", text: $store.draft)
                            .textFieldStyle(.registryInput)
                            .accessibilityLabel("New task")
                            .submitLabel(.done)
                            .onSubmit { store.send(.addButtonTapped) }
                        Button("Add") { store.send(.addButtonTapped) }
                            .buttonStyle(.registry)
                            .disabled(!store.canAdd)
                    }
                } label: {
                    HStack {
                        Label("Today", systemImage: "checklist")
                        Spacer()
                        Text("\(store.remainingCount) left")
                            .registryBadge(store.remainingCount == 0 ? .positive : .secondary)
                    }
                }
                .groupBoxStyle(.registryCard)

                // The tabs recipe: a segmented Picker is the whole treatment.
                Picker("Filter", selection: $store.filter) {
                    ForEach(Todos.Filter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)

                if store.visibleTodos.isEmpty {
                    ContentUnavailableView(
                        store.todos.isEmpty ? "Nothing to do" : "Nothing here",
                        systemImage: "checkmark.circle",
                        description: Text(
                            store.todos.isEmpty
                                ? "Add a task above to get started."
                                : "Change the filter to see the other tasks."
                        )
                    )
                    .registryEmptyState()
                } else {
                    GroupBox {
                        VStack(spacing: 0) {
                            ForEach(store.visibleTodos) { todo in
                                TodoRow(
                                    todo: todo,
                                    onToggle: { store.send(.doneToggled(todo.id, $0)) },
                                    onDelete: { store.send(.deleteButtonTapped(todo.id)) }
                                )
                                if todo.id != store.visibleTodos.last?.id {
                                    Divider().registrySeparator()
                                }
                            }
                        }
                    }
                    .groupBoxStyle(.registryCard)
                }

                if store.doneCount > 0 {
                    Button("Clear \(store.doneCount) completed", role: .destructive) {
                        store.send(.clearDoneButtonTapped)
                    }
                    .buttonStyle(.registryOutline)
                }
            }
            .padding()
        }
        .navigationTitle("Todos")
    }
}

private struct TodoRow: View {
    let todo: Todo
    let onToggle: @MainActor (Bool) -> Void
    let onDelete: @MainActor () -> Void
    @Environment(\.registryTheme) private var theme

    var body: some View {
        HStack(spacing: theme.metrics.compactSpacing) {
            Toggle(isOn: Binding(get: { todo.isDone }, set: onToggle)) {
                Text(todo.title)
                    .strikethrough(todo.isDone)
                    .foregroundStyle(todo.isDone ? .secondary : .primary)
            }
            .toggleStyle(.registryCheckbox)
            Spacer()
            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
            }
            .buttonStyle(.registryGhost)
            .accessibilityLabel("Delete \(todo.title)")
        }
        .padding(.vertical, theme.metrics.compactSpacing)
    }
}

#Preview("Todos") {
    NavigationStack {
        TodosView(
            store: Store(
                initialState: Todos.State(todos: [
                    Todo(id: UUID(), title: "Read the registry spec"),
                    Todo(id: UUID(), title: "Ship 0.1.0", isDone: true),
                ])
            ) {
                Todos()
            }
        )
    }
    .registryTheme(.app)
    .fontDesign(.rounded)
}
