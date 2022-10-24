import ComposableArchitecture

struct Score: ReducerProtocol {
    struct State: Equatable, Identifiable, Codable {
        let team: Team.State
        @BindableState var points: Int
        var accumulatedPoints: Int

        var id: Team.State.ID { team.id }
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case remove
    }

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
    }
}
