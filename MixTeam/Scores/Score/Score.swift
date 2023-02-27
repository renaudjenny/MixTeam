import ComposableArchitecture
import Foundation

struct Score: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: UUID
        var team: Team.State
        @BindingState var points: Int = 0

        var accumulatedPoints = 0
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case remove
    }

    @Dependency(\.scoresPersistence) var scorePersistence

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            if case let .binding(binding) = action, binding.keyPath == \.$points {
                return .fireAndForget { [state] in try await scorePersistence.updateScore(state) }
            }
            return .none
        }
    }
}
