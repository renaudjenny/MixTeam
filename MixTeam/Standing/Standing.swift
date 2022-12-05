import ComposableArchitecture

struct Standing: ReducerProtocol {
    struct State: Equatable {
        var players: IdentifiedArrayOf<Player.State> = []
    }

    enum Action: Equatable {
        case createPlayer
        case player(id: Player.State.ID, action: Player.Action)
    }

    @Dependency(\.uuid) var uuid

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .createPlayer:
                let name = ["Mathilde", "Renaud", "John", "Alice", "Bob", "CJ"].randomElement() ?? ""
                let image = MTImage.players.randomElement() ?? .unknown
                let player = Player.State(id: uuid(), name: name, image: image, color: .aluminium, isStanding: true)
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

extension Standing.State: Codable {
    enum CodingKeys: CodingKey {
        case players
    }
}
