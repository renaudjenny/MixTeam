import ComposableArchitecture

struct App: ReducerProtocol {
    struct State: Equatable {
        var teams: IdentifiedArrayOf<Team> = []
        var editedPlayer: Player?
        var editedTeam: Team?
        var notEnoughTeamsAlert: AlertState<Action>?
    }
    enum Action: Equatable {
        case saveTeams
        case loadTeams
        case addTeam
        case editTeam(Team)
        case finishEditingTeam
        case updateTeam(Team)
        case deleteTeam(Team)
        case createPlayer
        case editPlayer(Player)
        case finishEditingPlayer
        case updatePlayer(Player)
        case deletePlayer(Player)
        case moveBackPlayer(Player)
        case mixTeam
        case dismissNotEnoughTeamsAlert
    }
    @Dependency(\.saveTeams) var saveTeams
    @Dependency(\.loadedTeams) var loadedTeams

    // swiftlint:disable:next cyclomatic_complexity (TODO: decouple Teams and Players logic into a forEach)
    func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .saveTeams:
            saveTeams(state.teams.elements)
            return .none
        case .loadTeams:
            state.teams = IdentifiedArrayOf(uniqueElements: loadedTeams)
            return .none
        case .addTeam:
            let image = ImageIdentifier.teams.randomElement() ?? .koala
            let color = ColorIdentifier.allCases.randomElement() ?? .red
            let name = "\(color.name) \(image.name)".localizedCapitalized
            state.teams.updateOrAppend(Team(name: name, colorIdentifier: color, imageIdentifier: image))
            return Effect(value: .saveTeams)
        case let .editTeam(team):
            state.editedTeam = team
            return .none
        case .finishEditingTeam:
            state.editedTeam = nil
            return .none
        case let .updateTeam(team):
            state.teams.updateOrAppend(team)
            return Effect(value: .saveTeams)
        case let .deleteTeam(team):
            state.teams.remove(team)
            return .none
        case .createPlayer:
            let name = Player.placeholders.randomElement() ?? ""
            let image = ImageIdentifier.players.randomElement() ?? .unknown
            let player = Player(name: name, imageIdentifier: image)
            let firstTeamID = state.teams[0].id
            state.teams[id: firstTeamID]?.players.updateOrAppend(player)
            return Effect(value: .saveTeams)
        case let .editPlayer(player):
            state.editedPlayer = player
            return .none
        case .finishEditingPlayer:
            state.editedPlayer = nil
            return .none
        case let .updatePlayer(player):
            guard var team = state.teams.first(where: { $0.players.contains(player) }) else { return .none }
            team.players.updateOrAppend(player)
            state.teams.updateOrAppend(team)
            return Effect(value: .saveTeams)
        case let .deletePlayer(player):
            guard var team = state.teams.first(where: { $0.players.contains(player) }) else { return .none }
            team.players.remove(player)
            state.teams.updateOrAppend(team)
            return Effect(value: .saveTeams)
        case let .moveBackPlayer(player):
            guard var team = state.teams.first(where: { $0.players.contains(player) }) else { return .none }
            team.players.remove(player)
            state.teams.updateOrAppend(team)

            let firstTeamID = state.teams[0].id
            state.teams[id: firstTeamID]?.players.updateOrAppend(player)
            return Effect(value: .saveTeams)
        case .mixTeam:
            guard state.teams.count > 2 else {
                state.notEnoughTeamsAlert = AlertState(
                    title: TextState("Couldn't Mix Team with less than 2 teams. Go create some teams :)")
                )
                return .none
            }

            let players = state.teams.flatMap(\.players)
            guard players.count > 0 else { return .none }

            state.teams = IdentifiedArrayOf(uniqueElements: state.teams.map {
                var newTeam = $0
                newTeam.players = []
                return newTeam
            })

            state.teams = players.shuffled().reduce(state.teams) { teams, player in
                var teams = teams
                let availableTeams = teams.filter { $0 != teams.first }
                guard let lessPlayerTeam = availableTeams
                    .sorted(by: { $0.players.count < $1.players.count  })
                    .first
                else { return teams }
                teams[id: lessPlayerTeam.id]?.players.updateOrAppend(player)
                return teams
            }
            return Effect(value: .saveTeams)
        case .dismissNotEnoughTeamsAlert:
            state.notEnoughTeamsAlert = nil
            return .none
        }
    }
}
