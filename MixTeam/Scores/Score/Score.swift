import ComposableArchitecture
import Foundation

struct Score: ReducerProtocol {
    struct State: Equatable, Identifiable, Codable {
        let id: UUID
        let team: Team.State
        @BindableState var points: Int
        var accumulatedPoints: Int
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case remove
    }

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
    }
}
