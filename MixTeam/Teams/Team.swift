import AsyncAlgorithms
import ComposableArchitecture
import Foundation

struct Team: ReducerProtocol {
    struct State: Equatable, Identifiable, Hashable {
        let id: UUID
        @BindableState var name: String = ""
        @BindableState var color: MTColor = .aluminium
        @BindableState var image: MTImage = .unknown
        var playerIDs: [Player.State.ID] = []
        var isArchived = false

        var players: Players = .loading

        func hash(into hasher: inout Hasher) { hasher.combine(id) }
    }

    enum Players: Equatable {
        case loading
        case loaded(IdentifiedArrayOf<Player.State>)
        case error(String)
    }

    struct UpdateResult: Equatable {
        let teams: IdentifiedArrayOf<Team.State>
        let players: IdentifiedArrayOf<Player.State>
    }

    enum Action: BindableAction, Equatable {
        case bind
        case update(TaskResult<UpdateResult>)
        case binding(BindingAction<State>)
        case player(id: Player.State.ID, action: Player.Action)
    }

    @Dependency(\.uuid) var uuid
    @Dependency(\.appPersistence.team) var teamPersistence
    @Dependency(\.appPersistence.player) var playerPersistence

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .bind:
                return .run { send in
                    let teams = try await teamPersistence.load()
                    let players = try await playerPersistence.load()
                    await send(.update(TaskResult { @MainActor in UpdateResult(teams: teams, players: players) }))

                    let teamChannel = teamPersistence.channel()
                    let playerChannel = playerPersistence.channel()
                    for await (teams, players) in combineLatest(teamChannel, playerChannel) {
                        await send(.update(TaskResult { @MainActor in UpdateResult(teams: teams, players: players) }))
                    }

                }
                .animation(.default)
            case let .update(result):
                switch result {
                case let .success(result):
                    guard let team = result.teams.first(where: { $0.id == state.id }) else { return .none }
                    state = team
                    let players = result.players
                        .filter { team.playerIDs.contains($0.id) }
                        .map {
                            var player = $0
                            player.color = state.color
                            player.isStanding = false
                            return player
                        }
                    state.players = .loaded(IdentifiedArrayOf(uniqueElements: players))
                    return .none
                case let .failure(error):
                    state.players = .error(error.localizedDescription)
                    return .none
                }
            case .binding:
                return .fireAndForget { [state] in try await teamPersistence.updateOrAppend(state) }
            case let .player(id, .moveBack):
                state.playerIDs.removeAll { $0 == id }
                return .fireAndForget { [state] in
                    try await teamPersistence.updateOrAppend(state)
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
