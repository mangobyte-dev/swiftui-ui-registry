import ComposableArchitecture

/// The app root: two independent features composed with `Scope`.
@Reducer
public struct TodoCounter {
    @ObservableState
    public struct State: Equatable {
        public var counter = Counter.State()
        public var todos = Todos.State()

        public init(counter: Counter.State = Counter.State(), todos: Todos.State = Todos.State()) {
            self.counter = counter
            self.todos = todos
        }
    }

    public enum Action {
        case counter(Counter.Action)
        case todos(Todos.Action)
    }

    public init() {}

    public var body: some Reducer<State, Action> {
        Scope(state: \.counter, action: \.counter) {
            Counter()
        }
        Scope(state: \.todos, action: \.todos) {
            Todos()
        }
    }
}
