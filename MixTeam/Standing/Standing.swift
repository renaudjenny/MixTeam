import ComposableArchitecture

struct Standing: ReducerProtocol {
    enum State: Equatable {
        // TODO: remove playerIDs from loading, it's useless! In the case load action we are loading the standing
        // directly from its persistance and chaining with the players one
        case loading(playerIDs: [Player.State.ID])
        case loaded(players: IdentifiedArrayOf<Player.State>)
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
                guard case var .loaded(players) = state else { return .none }
                let name = ["Mathilde", "Renaud", "John", "Alice", "Bob", "CJ"].randomElement() ?? ""
                let image = MTImage.players.randomElement() ?? .unknown
                let player = Player.State(id: uuid(), name: name, image: image, color: .aluminium, isStanding: true)

                // TODO: This part could maybe be automatically done by a subscription to the playerPersistence stream?
                players.updateOrAppend(player)
                state = .loaded(players: players)
                // END of TODO

                return .fireAndForget { [state] in
                    try await playerPersistence.updateOrAppend(player)
                    try await standingPersistence.save(state)
                }
            case .load:
                return .task {
                    await .loaded(TaskResult {
                        guard case let .loading(ids) = try await standingPersistence.load()
                        else {
                            struct TODOError: Error {}
                            throw TODOError()
                        }
                        return try await playerPersistence.load().filter { ids.contains($0.id) }
                    })
                }
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

                // TODO: This part could maybe be automatically done by a subscription to the playerPersistence stream?
                players.remove(id: id)
                state = .loaded(players: players)
                // END of TODO

                return .fireAndForget { [state] in
                    try await playerPersistence.remove(id)
                    try await standingPersistence.save(state)
                }
            case let .player(id, _):
                // TODO: check if it's really necessary? Could it be done by subscribing to the playerPersistance stream?
                guard case var .loaded(players) = state, let player = players[id: id] else { return .none }
                players.updateOrAppend(player)
                state = .loaded(players: players)
                return .fireAndForget { [state] in
                    try await playerPersistence.updateOrAppend(player)
                    try await standingPersistence.save(state)
                }
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

extension Standing.State: Codable {
    enum CodingKeys: CodingKey {
        case playerIDs
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let playerIDs = try values.decode([Player.State.ID].self, forKey: .playerIDs)
        self = .loading(playerIDs: playerIDs)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .loading(playerIDs):
            try container.encode(playerIDs, forKey: .playerIDs)
        case let .loaded(players):
            try container.encode(players.map(\.id), forKey: .playerIDs)
        case let .error(errorString):
            throw EncodingError.invalidValue(
                self,
                EncodingError.Context(
                    codingPath: [CodingKeys.playerIDs],
                    debugDescription: "Cannot encore error state: \(errorString)"
                )
            )
        }
    }
}
