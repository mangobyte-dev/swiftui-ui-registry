import ComposableArchitecture
import SwiftUI

struct HandmadeTodosView: View {
    @Bindable var store: StoreOf<Todos>
    @Environment(\.handmadeTheme) private var theme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.metrics.sectionSpacing) {
                GroupBox {
                    HStack(spacing: theme.metrics.compactSpacing) {
                        TextField("Add a task", text: $store.draft)
                            .textFieldStyle(.handmadeInput)
                            .accessibilityLabel("New task")
                            .submitLabel(.done)
                            .onSubmit { store.send(.addButtonTapped) }
                        Button("Add") { store.send(.addButtonTapped) }
                            .buttonStyle(.handmade)
                            .disabled(!store.canAdd)
                    }
                } label: {
                    HStack {
                        Label("Today", systemImage: "checklist")
                        Spacer()
                        Text("\(store.remainingCount) left")
                            .handmadeBadge(store.remainingCount == 0 ? .positive : .secondary)
                    }
                }
                .groupBoxStyle(.handmadeCard)

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
                    .handmadeEmptyState()
                } else {
                    GroupBox {
                        VStack(spacing: 0) {
                            ForEach(store.visibleTodos) { todo in
                                HandmadeTodoRow(
                                    todo: todo,
                                    onToggle: { store.send(.doneToggled(todo.id, $0)) },
                                    onDelete: { store.send(.deleteButtonTapped(todo.id)) }
                                )
                                if todo.id != store.visibleTodos.last?.id {
                                    Divider().handmadeSeparator()
                                }
                            }
                        }
                    }
                    .groupBoxStyle(.handmadeCard)
                }

                if store.doneCount > 0 {
                    Button("Clear \(store.doneCount) completed", role: .destructive) {
                        store.send(.clearDoneButtonTapped)
                    }
                    .buttonStyle(.handmadeOutline)
                }
            }
            .padding()
        }
        .navigationTitle("Todos")
    }
}

private struct HandmadeTodoRow: View {
    let todo: Todo
    let onToggle: @MainActor (Bool) -> Void
    let onDelete: @MainActor () -> Void
    @Environment(\.handmadeTheme) private var theme

    var body: some View {
        HStack(spacing: theme.metrics.compactSpacing) {
            Toggle(isOn: Binding(get: { todo.isDone }, set: onToggle)) {
                Text(todo.title)
                    .strikethrough(todo.isDone)
                    .foregroundStyle(todo.isDone ? .secondary : .primary)
            }
            .toggleStyle(.handmadeCheckbox)
            Spacer()
            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
            }
            .buttonStyle(.handmadeGhost)
            .accessibilityLabel("Delete \(todo.title)")
        }
        .padding(.vertical, theme.metrics.compactSpacing)
    }
}
