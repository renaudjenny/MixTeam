import ComposableArchitecture

struct Standing: ReducerProtocol {
    struct State: Equatable {
        var playerIDs: [Player.State.ID]

        var players: Players = .loading {
            didSet {
                guard case let .loaded(players) = players else { return }
                playerIDs = players.map(\.id)
            }
        }
    }

    enum Players: Equatable {
        case loading
        case loaded(IdentifiedArrayOf<Player.State>)
        case error(String)
    }

    enum Action: Equatable {
        case createPlayer
        case load
        case loaded(TaskResult<IdentifiedArrayOf<Player.State>>)
        case player(id: Player.State.ID, action: Player.Action)
    }

    @Dependency(\.uuid) var uuid
    @Dependency(\.appPersistence.player) var playerPersistence
    @Dependency(\.appPersistence.standing) var standingPersistence

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .createPlayer:
                guard case var .loaded(players) = state.players else { return .none }
                let name = ["Mathilde", "Renaud", "John", "Alice", "Bob", "CJ"].randomElement() ?? ""
                let image = MTImage.players.randomElement() ?? .unknown
                let player = Player.State(id: uuid(), name: name, image: image, color: .aluminium, isStanding: true)
                players.updateOrAppend(player)
                state.players = .loaded(players)

                return .fireAndForget { [state] in
                    try await playerPersistence.updateOrAppend(player)
                    try await standingPersistence.save(state)
                }
            case .load:
                @Sendable func taskResult(
                    standingPlayerIDs: [Player.State.ID],
                    players: IdentifiedArrayOf<Player.State>
                ) async -> TaskResult<IdentifiedArrayOf<Player.State>> {
                    await TaskResult {
                        IdentifiedArrayOf(uniqueElements: players
                            .filter { standingPlayerIDs.contains($0.id) }
                            .map {
                                var player = $0
                                player.isStanding = true
                                return player
                            }
                        )
                    }
                }
                return .merge(
                    .task {
                        let ids = try await standingPersistence.load().playerIDs
                        let players = try await playerPersistence.load()
                        return .loaded(await taskResult(standingPlayerIDs: ids, players: players))
                    },
                    .run { send in
                        for try await standing in standingPersistence.stream() {
                            let ids = standing.playerIDs
                            let players = try await playerPersistence.load()
                            await send(.loaded(await taskResult(standingPlayerIDs: ids, players: players)))
                        }
                    },
                    .run { send in
                        for try await players in playerPersistence.stream() {
                            let ids = try await standingPersistence.load().playerIDs
                            await send(.loaded(await taskResult(standingPlayerIDs: ids, players: players)))
                        }
                    }
                )
                .animation(.default)
            case let .loaded(result):
                switch result {
                case let .success(players):
                    state.players = .loaded(players)
                    return .none
                case let .failure(error):
                    state.players = .error(error.localizedDescription)
                    return .none
                }
                // TODO: this should be managed by the Player reduced in theory
//            case let .player(id, action: .delete):
//                guard case var .loaded(players) = state.players else { return .none }
//                players.remove(id: id)
//
//                return .fireAndForget { [players] in
//                    try await standingPersistence.save(state)
//                }
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
