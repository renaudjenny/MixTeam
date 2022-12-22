import AsyncAlgorithms
import ComposableArchitecture
import Foundation

struct Team: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: UUID
        @BindableState var name: String = ""
        @BindableState var color: MTColor = .aluminium
        @BindableState var image: MTImage = .unknown
        var players: IdentifiedArrayOf<Player.State> = []
        var isArchived = false
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case player(id: Player.State.ID, action: Player.Action)
    }

    @Dependency(\.uuid) var uuid
    @Dependency(\.appPersistence.team) var teamPersistence

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .fireAndForget { [state] in try await teamPersistence.updateOrAppend(state) }
            case let .player(id, .moveBack):
                state.players.remove(id: id)
                return .fireAndForget { [state] in
                    try await teamPersistence.updateOrAppend(state)
                }
            case .player:
                return .none
            }
        }
        .forEach(\.players, action: /Team.Action.player) {
            Player()
        }
    }
}
