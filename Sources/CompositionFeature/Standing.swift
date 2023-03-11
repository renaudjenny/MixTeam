import ComposableArchitecture
import PlayersFeature

public struct Standing: ReducerProtocol {
    public struct State: Equatable {
        public var players: IdentifiedArrayOf<Player.State> = []

        public init(players: IdentifiedArrayOf<Player.State> = []) {
            self.players = players
        }
    }

    public enum Action: Equatable {
        case createPlayer
        case deletePlayer(id: Player.State.ID)
        case player(id: Player.State.ID, action: Player.Action)
    }

    @Dependency(\.uuid) var uuid
    @Dependency(\.playerPersistence) var playerPersistence
    @Dependency(\.randomPlayer) var randomPlayer

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .createPlayer:
                let player = randomPlayer()
                state.players.append(player)
                return .fireAndForget { try await playerPersistence.updateOrAppend(player.persisted) }
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
