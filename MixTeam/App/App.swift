import AsyncAlgorithms
import ComposableArchitecture
import SwiftUI

struct App: ReducerProtocol {
    struct State: Equatable {
        var teamIDs: [Team.State.ID] = []
        var _scores = Scores.State()

        var standing = Standing.State(playerIDs: [])
        var teams: Teams = .loading {
            didSet {
                guard case let .loaded(teams) = teams else { return }
                teamIDs = teams.map(\.id)
            }
        }
        var notEnoughTeamsAlert: AlertState<Action>?
    }

    enum Teams: Equatable {
        case loading
        case loaded(IdentifiedArrayOf<Team.State>)
        case error(String)
    }

    struct UpdateResult: Equatable {
        let state: State
        let teams: IdentifiedArrayOf<Team.State>
    }

    enum Action: Equatable {
        case bind
        case update(TaskResult<UpdateResult>)
        case addTeam
        case mixTeam
        case dismissNotEnoughTeamsAlert
        case standing(Standing.Action)
        case team(id: Team.State.ID, action: Team.Action)
        case deleteTeams(IndexSet)
        case scores(Scores.Action)
    }

    @Dependency(\.appPersistence) var appPersistence
    @Dependency(\.shufflePlayers) var shufflePlayers
    @Dependency(\.uuid) var uuid

    private enum LoadTaskID {}
    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.standing, action: /Action.standing) {
            Standing()
        }
        Scope(state: \.scores, action: /Action.scores) {
            Scores()
        }
        Reduce { state, action in
            switch action {
            case .bind:
                return .run { send in
                    let state = try await appPersistence.load()
                    let teams = try await appPersistence.team.load()
                    await send(.update(TaskResult { @MainActor in UpdateResult(state: state, teams: teams) }))

                    let appChannel = appPersistence.channel()
                    let teamChannel = appPersistence.team.channel()
                    for await (state, teams) in combineLatest(appChannel, teamChannel) {
                        await send(.update(TaskResult { @MainActor in UpdateResult(state: state, teams: teams) }))
                    }
                }
                .animation(.default)
            case let .update(result):
                switch result {
                case let .success(result):
                    state = result.state
                    state.teams = .loaded(result.teams.filter { state.teamIDs.contains($0.id) })
                    return .none
                case let .failure(error):
                    state.teams = .error(error.localizedDescription)
                    return .none
                }
            case .addTeam:
                let image = MTImage.teams.randomElement() ?? .koala
                let color = MTColor.allCases.filter({ $0 != .aluminium }).randomElement() ?? .aluminium
                let name = "\(color.rawValue) \(image.rawValue)".localizedCapitalized
                let team = Team.State(id: uuid(), name: name, color: color, image: image)
                state.teamIDs.append(team.id)
                return .fireAndForget { [state] in
                    try await appPersistence.team.updateOrAppend(team)
                    try await appPersistence.save(state)
                }
            case .mixTeam:
                guard state.teamIDs.count > 1,
                      case var .loaded(teams) = state.teams
                else {
                    state.notEnoughTeamsAlert = .notEnoughTeams
                    return .none
                }
                let playerIDs = state.standing.playerIDs + teams.flatMap(\.playerIDs)
                guard playerIDs.count > 0 else { return .none }

                teams = IdentifiedArrayOf(uniqueElements: teams.map {
                    var team = $0
                    team.playerIDs = []
                    return team
                })

                teams = shufflePlayers(playerIDs: playerIDs).reduce(teams) { teams, playerID in
                    var teams = teams
                    guard let lessPlayerTeam = teams
                        .sorted(by: { $0.playerIDs.count < $1.playerIDs.count })
                        .first
                    else { return teams }
                    teams[id: lessPlayerTeam.id]?.playerIDs.append(playerID)
                    return teams
                }
                state.standing.playerIDs = []
                return .fireAndForget { [state, teams] in
                    try await appPersistence.team.save(teams)
                    try await appPersistence.standing.save(state.standing)
                }
            case .dismissNotEnoughTeamsAlert:
                state.notEnoughTeamsAlert = nil
                return .none
            case .standing:
                return .none
            case let .team(_, .player(id, .moveBack)):
                state.standing.playerIDs.append(id)
                return .fireAndForget { [standing = state.standing] in
                    try await appPersistence.standing.save(standing)
                }
            case .team:
                return .none
            case let .deleteTeams(indexSet):
                guard case var .loaded(teams) = state.teams else { return .none }
                for index in indexSet {
                    state.standing.playerIDs.append(contentsOf: teams[index].playerIDs)
                }
                teams.remove(atOffsets: indexSet)
                state.teamIDs.remove(atOffsets: indexSet)
                return .fireAndForget { [state, teams] in
                    try await appPersistence.save(state)
                    try await appPersistence.standing.save(state.standing)
                    try await appPersistence.team.save(teams)
                }
            case .scores:
                return .none
            }
        }
        Scope(state: \.teams, action: /Action.team) {
            EmptyReducer()
                .ifCaseLet(/Teams.loaded, action: /.self) {
                    EmptyReducer()
                        .forEach(\.self, action: /.self) {
                            Team()
                        }
                }
        }
    }
}

extension App.State: Codable {
    enum CodingKeys: CodingKey {
        case teamIDs
        case _scores
    }
}
