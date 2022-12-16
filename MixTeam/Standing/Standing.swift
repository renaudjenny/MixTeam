import ComposableArchitecture

struct Standing: ReducerProtocol {
    enum State: Equatable {
        case loading
        case loaded(players: IdentifiedArrayOf<Player.State>)
        case error(String)
    }

    // TODO: refactor that the way we've done App or Team States
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
