import ComposableArchitecture
import Foundation

/// The todo list as a Composable Architecture feature: value state, a typed action per user
/// intent, and a pure reducer. The registry items below it only style native controls.
@Reducer
public struct Todos {
    @ObservableState
    public struct State: Equatable {
        public var draft = ""
        public var filter: Filter = .all
        public var todos: IdentifiedArrayOf<Todo> = []

        public init(draft: String = "", filter: Filter = .all, todos: IdentifiedArrayOf<Todo> = []) {
            self.draft = draft
            self.filter = filter
            self.todos = todos
        }

        public var canAdd: Bool {
            !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        public var doneCount: Int { todos.filter(\.isDone).count }

        public var remainingCount: Int { todos.count - doneCount }

        public var visibleTodos: IdentifiedArrayOf<Todo> {
            switch filter {
            case .all: todos
            case .active: todos.filter { !$0.isDone }
            case .done: todos.filter(\.isDone)
            }
        }
    }

    public enum Filter: String, CaseIterable, Sendable {
        case all = "All"
        case active = "Active"
        case done = "Done"
    }

    public enum Action: BindableAction {
        case addButtonTapped
        case binding(BindingAction<State>)
        case clearDoneButtonTapped
        case deleteButtonTapped(Todo.ID)
        case doneToggled(Todo.ID, Bool)
    }

    @Dependency(\.uuid) var uuid

    public init() {}

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                let title = state.draft.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !title.isEmpty else { return .none }
                state.todos.insert(Todo(id: uuid(), title: title), at: 0)
                state.draft = ""
                return .none

            case .binding:
                return .none

            case .clearDoneButtonTapped:
                state.todos.removeAll(where: \.isDone)
                return .none

            case .deleteButtonTapped(let id):
                state.todos.remove(id: id)
                return .none

            case .doneToggled(let id, let isDone):
                state.todos[id: id]?.isDone = isDone
                return .none
            }
        }
    }
}
