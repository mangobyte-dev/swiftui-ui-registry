import ComposableArchitecture

/// Point-Free's counter, the running example of their state-management arc (episode 65
/// onward) and the first feature in the Composable Architecture's own documentation.
@Reducer
public struct Counter {
    @ObservableState
    public struct State: Equatable {
        public var count = 0

        public init(count: Int = 0) {
            self.count = count
        }

        /// The prime check from the original counter demo, kept pure and testable.
        public var isPrime: Bool {
            guard count >= 2 else { return false }
            var divisor = 2
            while divisor * divisor <= count {
                if count % divisor == 0 { return false }
                divisor += 1
            }
            return true
        }
    }

    public enum Action {
        case decrementButtonTapped
        case incrementButtonTapped
        case resetButtonTapped
    }

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .decrementButtonTapped:
                state.count -= 1
                return .none

            case .incrementButtonTapped:
                state.count += 1
                return .none

            case .resetButtonTapped:
                state.count = 0
                return .none
            }
        }
    }
}
