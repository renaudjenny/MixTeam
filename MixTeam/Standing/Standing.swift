import ComposableArchitecture

struct Standing: ReducerProtocol {
    // TODO: Use enum State instead? See
    // https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/reducerprotocol/ifcaselet(_:action:then:file:fileid:line:)
    struct State: Equatable {
        var players: IdentifiedArrayOf<Player.State> = []

        var playersState: PlayersState = .loading
    }

    enum PlayersState: Equatable {
        case loading
        case loaded(IdentifiedArrayOf<Player.State>)
        case error
    }

    enum Action: Equatable {
        case createPlayer
        case load
        case loaded(TaskResult<IdentifiedArrayOf<Player.State>>)
        case player(id: Player.State.ID, action: Player.Action)
    }

    @Dependency(\.uuid) var uuid
    @Dependency(\.appPersistence.player) var playerPersistence

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .createPlayer:
                let name = ["Mathilde", "Renaud", "John", "Alice", "Bob", "CJ"].randomElement() ?? ""
                let image = MTImage.players.randomElement() ?? .unknown
                let player = Player.State(id: uuid(), name: name, image: image, color: .aluminium, isStanding: true)
                state.players.updateOrAppend(player)
                return .fireAndForget {
                    var players = try await playerPersistence.load()
                    players.updateOrAppend(player)
                    try await playerPersistence.save(players)
                }
            case .load:
                return .task {
                    await .loaded(TaskResult {
                        try await playerPersistence.load()
                    })
                }
                .animation(.default)
            case let .loaded(result):
                switch result {
                case let .success(players):
                    state.players = players
                    state.playersState = .loaded(players)
                    return .none
                case .failure:
                    state.playersState = .error
                    return .none
                }
            case let .player(id, action: .delete):
                state.players.remove(id: id)
                return .fireAndForget {
                    var players = try await playerPersistence.load()
                    players.remove(id: id)
                    try await playerPersistence.save(players)
                }
            case let .player(id, _):
                guard let player = state.players[id: id] else { return .none }
                return .fireAndForget {
                    var players = try await playerPersistence.load()
                    players.updateOrAppend(player)
                    try await playerPersistence.save(players)
                }
            }
        }
        .forEach(\.players, action: /Standing.Action.player) {
            Player()
        }
    }
}

extension Standing.State: Codable {
    enum CodingKeys: CodingKey {
        case playerIDs
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let playerIDs = try values.decode([Player.State.ID].self, forKey: .playerIDs)
        players = IdentifiedArrayOf(uniqueElements: playerIDs.map { Player.State(id: $0) })
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(players.map(\.id), forKey: .playerIDs)
    }
}
