import AsyncAlgorithms
import ComposableArchitecture

struct Standing: ReducerProtocol {
    struct State: Equatable {
        var playerIDs: [Player.State.ID] = []

        var players: Players = .loading
    }

    enum Players: Equatable {
        case loading
        case loaded(IdentifiedArrayOf<Player.State>)
        case error(String)
    }

    struct UpdatedResult: Equatable {
        let players: IdentifiedArrayOf<Player.State>
    }

    enum Action: Equatable {
        case bind
        case updated(TaskResult<UpdatedResult>)
        case createPlayer
        case player(id: Player.State.ID, action: Player.Action)
    }

    @Dependency(\.uuid) var uuid
    @Dependency(\.appPersistence) var appPersistence
    @Dependency(\.appPersistence.player) var playerPersistence

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .bind:
                return .run { @MainActor send in
                    let players = try await playerPersistence.load()
                    await send(.updated(TaskResult { UpdatedResult(players: players) }))

                    let playerChannel = playerPersistence.channel()
                    for await players in playerChannel {
                        await send(.updated(TaskResult { UpdatedResult(players: players) }))
                    }
                }
                .animation(.default)
            case let .updated(result):
                switch result {
                case let .success(result):
                    let players = result.players
                        .filter { state.playerIDs.contains($0.id) }
                        .map {
                            var player = $0
                            player.color = .aluminium
                            player.isStanding = true
                            return player
                        }
                    state.players = .loaded(IdentifiedArrayOf(uniqueElements: players))
                    return .none
                case let .failure(error):
                    state.players = .error(error.localizedDescription)
                    return .none
                }
            case .createPlayer:
                let name = ["Mathilde", "Renaud", "John", "Alice", "Bob", "CJ"].randomElement() ?? ""
                let image = MTImage.players.randomElement() ?? .unknown
                let player = Player.State(id: uuid(), name: name, image: image, color: .aluminium, isStanding: true)
                state.playerIDs.append(player.id)

                return .fireAndForget { [state] in
                    try await appPersistence.saveStanding(state)
                    try await playerPersistence.updateOrAppend(player)
                }
            case let .player(id, .delete):
                state.playerIDs.removeAll(where: { $0 == id })
                return .fireAndForget { [state] in
                    try await appPersistence.saveStanding(state)
                    try await playerPersistence.remove(id)
                }
            case .player:
                return .none
            }
        }
        Scope(state: \.players, action: /Action.player, {
            EmptyReducer()
                .ifCaseLet(/Players.loaded, action: /.self) {
                    EmptyReducer()
                        .forEach(\.self, action: /.self) {
                            Player()
                        }
                }
        })
    }
}

extension Standing.State: Codable {
    enum CodingKeys: CodingKey {
        case playerIDs
    }
}
