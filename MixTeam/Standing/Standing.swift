import AsyncAlgorithms
import ComposableArchitecture

struct Standing: ReducerProtocol {
    struct State: Equatable {
        var players: IdentifiedArrayOf<Player.State> = []
    }

    struct UpdatedResult: Equatable {
        let players: IdentifiedArrayOf<Player.State>
    }

    enum Action: Equatable {
        case createPlayer
        case player(id: Player.State.ID, action: Player.Action)
    }

    @Dependency(\.uuid) var uuid
    @Dependency(\.appPersistence) var appPersistence
    @Dependency(\.appPersistence.player) var playerPersistence

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .createPlayer:
                let name = ["Mathilde", "Renaud", "John", "Alice", "Bob", "CJ"].randomElement() ?? ""
                let image = MTImage.players.randomElement() ?? .unknown
                let player = Player.State(id: uuid(), name: name, image: image, color: .aluminium, isStanding: true)
                state.players.append(player)

                return .fireAndForget { [state] in
                    try await appPersistence.saveStanding(state)
                    try await playerPersistence.updateOrAppend(player)
                }
            case let .player(id, .delete):
                state.players.remove(id: id)
                return .fireAndForget { [state] in
                    try await appPersistence.saveStanding(state)
                    try await playerPersistence.remove(id)
                }
            case .player:
                return .none
            }
        }
        .forEach(\.players, action: /Action.player) {
            Player()
        }
    }
}
