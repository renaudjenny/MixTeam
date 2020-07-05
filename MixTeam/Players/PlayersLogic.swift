import SwiftUI
import Combine

protocol PlayersLogic {
    var teamsStore: TeamsStore { get }
    var teams: [Team] { get }
    var presentedAlertBinding: Binding<PlayersView.PresentedAlert?> { get }

    func mixTeam()

    func createPlayer(name: String, image: ImageIdentifier)
    func editPlayer(_ player: Player)
    func deletePlayer(_ player: Player)
}

extension PlayersLogic {
    var teams: [Team] { teamsStore.teams }

    func mixTeam() {
        guard teams.count > 2 else {
            presentedAlertBinding.wrappedValue = .notEnoughTeams
            return
        }

        randomizeTeam()
    }

    func createPlayer(name: String, image: ImageIdentifier) {
        guard var playersStandingForATeam = teams.first else { return }
        playersStandingForATeam.players.append(Player(name: name, imageIdentifier: image))
        teamsStore.teams[0] = playersStandingForATeam
    }

    func editPlayer(_ player: Player) {
        guard let teamIndex = teamsStore.teams.firstIndex(where: { $0.players.contains(player) }),
            let playerIndex = teamsStore.teams[teamIndex].players.firstIndex(of: player) else {
                return
        }
        teamsStore.teams[teamIndex].players[playerIndex] = player
    }

    func deletePlayer(_ player: Player) {
        guard let teamIndex = teamsStore.teams.firstIndex(where: { $0.players.contains(player) }),
            let playerIndex = teamsStore.teams[teamIndex].players.firstIndex(of: player) else {
                return
        }
        teamsStore.teams[teamIndex].players.remove(at: playerIndex)
    }
}

extension PlayersLogic {
    private func randomizeTeam() {
        let players = teams.flatMap(\.players)
        guard players.count > 0 else { return }
        guard teams.filter({ $0 != teams.first }).count > 1 else { return }

        teamsStore.teams = teams.map({
            var newTeam = $0
            newTeam.players = []
            return newTeam
        })

        teamsStore.teams = players.shuffled().reduce(teams) { teams, player in
            var teams = teams
            let availableTeams = teams.filter { $0 != teams.first }
            guard let lessPlayerTeam = availableTeams.sorted(by: hasLessPlayer).first,
                let teamIndex = teams.firstIndex(of: lessPlayerTeam) else { return teams }
            teams[teamIndex].players += [player]
            return teams
        }
    }

    private func hasLessPlayer(teamA a: Team, teamB b: Team) -> Bool {
        a.players.count < b.players.count
    }
}
