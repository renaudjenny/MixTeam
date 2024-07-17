import ComposableArchitecture
import PlayersFeature

@Reducer
public struct Standing {
    @ObservableState
    public struct State: Equatable {
        public var players: IdentifiedArrayOf<Player.State> = []

        public init(players: IdentifiedArrayOf<Player.State> = []) {
            self.players = players
        }
    }

    public enum Action: Equatable {
        case createPlayer
        case deletePlayer(id: Player.State.ID)
        case player(IdentifiedActionOf<Player>)
    }

    @Dependency(\.uuid) var uuid
    @Dependency(\.legacyPlayerPersistence) var legacyPlayerPersistence
    @Dependency(\.randomPlayer) var randomPlayer

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .createPlayer:
                let player = randomPlayer()
                state.players.append(player)
                return .run { _ in try await legacyPlayerPersistence.updateOrAppend(player.persisted) }
            case let .deletePlayer(id):
                state.players.remove(id: id)
                return .run { _ in try await legacyPlayerPersistence.remove(id) }
            case .player:
                return .none
            }
        }
        .forEach(\.players, action: \.player) {
            Player()
        }
    }
}
