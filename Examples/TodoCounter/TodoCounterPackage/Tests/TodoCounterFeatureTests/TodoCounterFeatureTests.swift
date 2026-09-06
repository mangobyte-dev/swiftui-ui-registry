import ComposableArchitecture
import Foundation
import Testing

@testable import TodoCounterFeature

@MainActor
struct TodosTests {
    @Test func addingTrimsTheDraftAndPrependsTheTodo() async {
        let store = TestStore(initialState: Todos.State(draft: "  Buy milk ")) {
            Todos()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        await store.send(.addButtonTapped) {
            $0.draft = ""
            $0.todos = [Todo(id: UUID(0), title: "Buy milk")]
        }
        await store.send(.binding(.set(\.draft, "Call mom"))) {
            $0.draft = "Call mom"
        }
        await store.send(.addButtonTapped) {
            $0.draft = ""
            $0.todos = [Todo(id: UUID(1), title: "Call mom"), Todo(id: UUID(0), title: "Buy milk")]
        }
    }

    @Test func blankDraftAddsNothing() async {
        let store = TestStore(initialState: Todos.State(draft: "   ")) {
            Todos()
        }
        #expect(!store.state.canAdd)
        await store.send(.addButtonTapped)
    }

    @Test func togglingFilteringAndClearing() async {
        let first = Todo(id: UUID(0), title: "First")
        let second = Todo(id: UUID(1), title: "Second")
        let store = TestStore(initialState: Todos.State(todos: [first, second])) {
            Todos()
        }
        await store.send(.doneToggled(first.id, true)) {
            $0.todos[id: first.id]?.isDone = true
        }
        #expect(store.state.remainingCount == 1)
        #expect(store.state.doneCount == 1)
        await store.send(.binding(.set(\.filter, .done))) {
            $0.filter = .done
        }
        #expect(store.state.visibleTodos.map(\.title) == ["First"])
        await store.send(.binding(.set(\.filter, .active))) {
            $0.filter = .active
        }
        #expect(store.state.visibleTodos.map(\.title) == ["Second"])
        await store.send(.clearDoneButtonTapped) {
            $0.todos = [second]
        }
        await store.send(.deleteButtonTapped(second.id)) {
            $0.todos = []
        }
        #expect(store.state.visibleTodos.isEmpty)
    }
}

@MainActor
struct CounterTests {
    @Test func countsAndKnowsPrimes() async {
        let store = TestStore(initialState: Counter.State()) {
            Counter()
        }
        #expect(!store.state.isPrime)
        await store.send(.incrementButtonTapped) { $0.count = 1 }
        #expect(!store.state.isPrime)
        await store.send(.incrementButtonTapped) { $0.count = 2 }
        #expect(store.state.isPrime)
        await store.send(.incrementButtonTapped) { $0.count = 3 }
        await store.send(.incrementButtonTapped) { $0.count = 4 }
        #expect(!store.state.isPrime)
        await store.send(.decrementButtonTapped) { $0.count = 3 }
        #expect(store.state.isPrime)
        await store.send(.resetButtonTapped) { $0.count = 0 }
        #expect(!Counter.State(count: -7).isPrime)
        #expect(Counter.State(count: 97).isPrime)
    }
}
