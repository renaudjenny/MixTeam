import ComposableArchitecture

struct Standing: ReducerProtocol {
    enum State: Equatable {
        case loading
        case loaded(players: IdentifiedArrayOf<Player.State>)
        case error(String)
    }

    struct Persistence: Codable {
        let playerIDs: [Player.State.ID]
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
                guard case var .loaded(players) = state else { return .none }
                let name = ["Mathilde", "Renaud", "John", "Alice", "Bob", "CJ"].randomElement() ?? ""
                let image = MTImage.players.randomElement() ?? .unknown
                let player = Player.State(id: uuid(), name: name, image: image, color: .aluminium, isStanding: true)
                players.updateOrAppend(player)

                return .fireAndForget { [players] in
                    try await playerPersistence.updateOrAppend(player)
                    try await standingPersistence.save(Persistence(playerIDs: players.map(\.id)))
                }
            case .load:
                // TODO: optimise and refactor redundant code in the load section (delegate to the loaded section!)
                return .merge(
                    .task {
                        await .loaded(TaskResult {
                            let ids = try await standingPersistence.load().playerIDs
                            return IdentifiedArrayOf(uniqueElements: try await playerPersistence.load()
                                .filter { ids.contains($0.id) }
                                .map {
                                    var player = $0
                                    player.isStanding = true
                                    return player
                                })
                        })
                    },
                    .run { send in
                        for try await standing in standingPersistence.stream() {
                            let ids = standing.playerIDs
                            await send(.loaded(TaskResult {
                                IdentifiedArrayOf(uniqueElements: try await playerPersistence.load()
                                    .filter { ids.contains($0.id) }
                                    .map {
                                        var player = $0
                                        player.isStanding = true
                                        return player
                                    })
                            }))
                        }
                    },
                    .run { send in
                        for try await players in playerPersistence.stream() {
                            let ids = try await standingPersistence.load().playerIDs
                            await send(.loaded(TaskResult {
                                IdentifiedArrayOf(uniqueElements: players
                                    .filter { ids.contains($0.id) }
                                    .map {
                                        var player = $0
                                        player.isStanding = true
                                        return player
                                    })
                            }))
                        }
                    }
                )
                .animation(.default)
            case let .loaded(result):
                switch result {
                case let .success(players):
                    state = .loaded(players: players)
                    return .none
                case let .failure(error):
                    state = .error(error.localizedDescription)
                    return .none
                }
            case let .player(id, action: .delete):
                guard case var .loaded(players) = state else { return .none }
                players.remove(id: id)

                return .fireAndForget { [players] in
                    try await standingPersistence.save(Persistence(playerIDs: players.map(\.id)))
                }
            case .player:
                return .none
            }
        }
        .ifCaseLet(/State.loaded(players:), action: /Action.player) {
            EmptyReducer()
                .forEach(\.self, action: /.self) {
                    Player()
                }
        }
    }
}
