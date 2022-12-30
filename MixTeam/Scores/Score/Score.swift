import ComposableArchitecture
import Foundation

struct Score: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: UUID
        var team: Team.State
        @BindableState var points: Int = 0

        var accumulatedPoints = 0
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case remove
    }

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
    }
}
