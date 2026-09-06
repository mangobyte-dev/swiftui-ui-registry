import ComposableArchitecture
import SwiftUI

struct PlainTodosView: View {
    @Bindable var store: StoreOf<Todos>

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                GroupBox {
                    HStack {
                        TextField("Add a task", text: $store.draft)
                            .accessibilityLabel("New task")
                            .submitLabel(.done)
                            .onSubmit { store.send(.addButtonTapped) }
                        Button("Add") { store.send(.addButtonTapped) }
                            .disabled(!store.canAdd)
                    }
                } label: {
                    HStack {
                        Label("Today", systemImage: "checklist")
                        Spacer()
                        Text("\(store.remainingCount) left")
                            .font(.caption)
                    }
                }

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
                } else {
                    GroupBox {
                        VStack(spacing: 0) {
                            ForEach(store.visibleTodos) { todo in
                                PlainTodoRow(
                                    todo: todo,
                                    onToggle: { store.send(.doneToggled(todo.id, $0)) },
                                    onDelete: { store.send(.deleteButtonTapped(todo.id)) }
                                )
                                if todo.id != store.visibleTodos.last?.id {
                                    Divider()
                                }
                            }
                        }
                    }
                }

                if store.doneCount > 0 {
                    Button("Clear \(store.doneCount) completed", role: .destructive) {
                        store.send(.clearDoneButtonTapped)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Todos")
    }
}

private struct PlainTodoRow: View {
    let todo: Todo
    let onToggle: @MainActor (Bool) -> Void
    let onDelete: @MainActor () -> Void

    var body: some View {
        HStack {
            Toggle(isOn: Binding(get: { todo.isDone }, set: onToggle)) {
                Text(todo.title)
                    .strikethrough(todo.isDone)
                    .foregroundStyle(todo.isDone ? .secondary : .primary)
            }
            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
            }
            .accessibilityLabel("Delete \(todo.title)")
        }
        .padding(.vertical, 8)
    }
}
