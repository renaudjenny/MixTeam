import ComposableArchitecture

struct Standing: ReducerProtocol {
    struct State: Equatable {
        var players: IdentifiedArrayOf<Player.State> = []
    }

    enum Action: Equatable {
        case createPlayer
        case deletePlayer(id: Player.State.ID)
        case player(id: Player.State.ID, action: Player.Action)
    }

    @Dependency(\.uuid) var uuid
    @Dependency(\.playerPersistence) var playerPersistence
    @Dependency(\.randomPlayer) var randomPlayer

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .createPlayer:
                let player = randomPlayer()
                state.players.append(player)
                return .fireAndForget { try await playerPersistence.updateOrAppend(player) }
            case let .deletePlayer(id):
                state.players.remove(id: id)
                return .fireAndForget { try await playerPersistence.remove(id) }
            case .player:
                return .none
            }
        }
        .forEach(\.players, action: /Action.player) {
            Player()
        }
    }
}
