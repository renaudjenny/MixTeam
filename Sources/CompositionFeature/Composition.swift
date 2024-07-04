import ComposableArchitecture
import Foundation
import Models
import PersistenceCore
import TeamsFeature

@Reducer
public struct Composition {
    @ObservableState
    public struct State: Equatable {
        public var teams: IdentifiedArrayOf<Team.State> = []
        public var standing = Standing.State()
        public var notEnoughTeamsConfirmationDialog: ConfirmationDialogState<Action>?

        public init(
            teams: IdentifiedArrayOf<Team.State> = [],
            standing: Standing.State = Standing.State(),
            notEnoughTeamsConfirmationDialog: ConfirmationDialogState<Action>? = nil
        ) {
            self.teams = teams
            self.standing = standing
            self.notEnoughTeamsConfirmationDialog = notEnoughTeamsConfirmationDialog
        }
    }

    public enum Action: Equatable {
        case addTeam
        case mixTeam
        case dismissNotEnoughTeamsAlert
        case standing(Standing.Action)
        case team(id: Team.State.ID, action: Team.Action)
        case archiveTeams(IndexSet)
    }

    @Dependency(\.teamPersistence) var teamPersistance
    @Dependency(\.shufflePlayers) var shufflePlayers
    @Dependency(\.randomTeam) var randomTeam
    @Dependency(\.uuid) var uuid

    public init() {}

    public var body: some Reducer<State, Action> {
        Scope(state: \.standing, action: /Action.standing) {
            Standing()
        }
        Reduce { state, action in
            switch action {
            case .addTeam:
                let team = randomTeam()
                state.teams.append(team)
                return .run { _ in try await teamPersistance.updateOrAppend(team.persisted) }
            case .mixTeam:
                guard state.teams.count > 1 else {
                    state.notEnoughTeamsConfirmationDialog = .notEnoughTeams
                    return .none
                }
                let players = state.standing.players + state.teams.flatMap(\.players)
                guard players.count > 0 else { return .none }

                state.teams = IdentifiedArrayOf(uniqueElements: state.teams.map {
                    var team = $0
                    team.players = []
                    return team
                })

                state.teams = IdentifiedArrayOf(
                    uniqueElements: shufflePlayers(players: players.elements).reduce(state.teams) { teams, player in
                        var teams = teams
                        var player = player
                        guard let lessPlayerTeam = teams
                            .sorted(by: { $0.players.count < $1.players.count })
                            .first
                        else { return teams }
                        guard var team = teams[id: lessPlayerTeam.id] else { return teams }
                        player.color = team.color
                        team.players.updateOrAppend(player)
                        teams.updateOrAppend(team)
                        return teams
                    }
                )
                state.standing.players = []
                return .run { [state] _ in try await teamPersistance.updateValues(state.teams.persisted) }
            case .dismissNotEnoughTeamsAlert:
                state.notEnoughTeamsConfirmationDialog = nil
                return .none
            case .standing:
                return .none
            case .team:
                return .none
            case let .archiveTeams(indexSet):
                let archivedTeams: IdentifiedArrayOf<Team.State> = IdentifiedArrayOf(
                    uniqueElements: indexSet.map { state.teams[$0] }
                )
                state.teams.remove(atOffsets: indexSet)
                return .run { _ in
                    let archivedTeams = IdentifiedArrayOf(uniqueElements: archivedTeams.map {
                        var team = $0
                        team.players = []
                        team.isArchived = true
                        return team
                    })
                    try await teamPersistance.updateValues(archivedTeams.persisted)
                }
            }
        }
        .forEach(\.teams, action: /Action.team) {
            Team()
        }
    }
}

extension IdentifiedArrayOf<Team.State> {
    var persisted: IdentifiedArrayOf<PersistedTeam> {
        IdentifiedArrayOf<PersistedTeam>(uniqueElements: map(\.persisted))
    }
}
