import ComposableArchitecture
import Foundation

struct Team: ReducerProtocol {
    struct State: Equatable, Identifiable, Hashable {
        let id: UUID
        @BindableState var name: String = ""
        var color: MTColor = .aluminium
        @BindableState var image: MTImage = .unknown
        var playerIDs: [Player.State.ID] = []
        var isArchived = false

        var players: Players = .loading {
            didSet {
                guard case let .loaded(players) = players else { return }
                playerIDs = players.map(\.id)
            }
        }

        func hash(into hasher: inout Hasher) { hasher.combine(id) }
    }

    enum Players: Equatable {
        case loading
        case loaded(IdentifiedArrayOf<Player.State>)
        case error(String)
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case setColor(MTColor)
        case load
        case loaded(TaskResult<IdentifiedArrayOf<Player.State>>)
        case player(id: Player.State.ID, action: Player.Action)
    }

    @Dependency(\.uuid) var uuid
    @Dependency(\.appPersistence.team) var teamPersistence
    @Dependency(\.appPersistence.player) var playerPersistence

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .setColor(color):
                state.color = color
                guard case var .loaded(players) = state.players else { return .none }
                for id in players.map(\.id) {
                    players[id: id]?.color = color
                }
                state.players = .loaded(players)
                return .fireAndForget { [state] in try await teamPersistence.updateOrAppend(state) }
            case .binding:
                return .fireAndForget { [state] in try await teamPersistence.updateOrAppend(state) }
            case .load:
                let state = state
                @Sendable func taskResult(
                    players: IdentifiedArrayOf<Player.State>
                ) async -> TaskResult<IdentifiedArrayOf<Player.State>> {
                    await TaskResult {
                        IdentifiedArrayOf(uniqueElements: players
                            .filter { state.playerIDs.contains($0.id) }
                            .map {
                                var player = $0
                                player.color = state.color
                                return player
                            })
                    }
                }
                return .merge(
                    .task {
                        let players = try await playerPersistence.load()
                        return .loaded(await taskResult(players: players))
                    }
                    // TODO: add .run with subscription to the playerPersistence stream
                )
            case let .loaded(result):
                switch result {
                case let .success(players):
                    state.players = .loaded(players)
                    return .none
                case let .failure(error):
                    state.players = .error(error.localizedDescription)
                    return .none
                }
            case .player:
                return .none
            }
        }
        Scope(state: \.players, action: /Action.player) {
            EmptyReducer()
                .ifCaseLet(/Players.loaded, action: /.self) {
                    EmptyReducer()
                        .forEach(\.self, action: /.self) {
                            Player()
                        }
                }
        }
    }
}

extension Team.State: Codable {
    enum CodingKeys: CodingKey {
        case id
        case name
        case color
        case image
        case playerIDs
        case isArchived
    }
}
