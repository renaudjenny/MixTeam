import ComposableArchitecture

struct Standing: ReducerProtocol {
    struct State: Equatable, Codable {
        var players: IdentifiedArrayOf<Player.State> = []
    }

    enum Action: Equatable {
        case createPlayer
        case updatePlayer(Player.State)
        case player(id: Player.State.ID, action: Player.Action)
    }

    @Dependency(\.uuid) var uuid

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .createPlayer:
                let name = ["Mathilde", "Renaud", "John", "Alice", "Bob", "CJ"].randomElement() ?? ""
                let image = ImageIdentifier.players.randomElement() ?? .unknown
                let player = Player.State(id: uuid(), name: name, image: image, isStanding: true, color: .gray)
                state.players.updateOrAppend(player)
                return .none
            case let .updatePlayer(player):
                state.players.updateOrAppend(player)
                return .none
            case let .player(id, action: .delete):
                state.players.remove(id: id)
                return .none
            case .player:
                return .none
            }
        }
        .forEach(\.players, action: /Standing.Action.player) {
            Player()
        }
    }
}
