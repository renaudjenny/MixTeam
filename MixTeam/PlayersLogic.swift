import SwiftUI
import Combine

protocol PlayersLogic {
    var teamsStore: TeamsStore { get }
    var teams: [Team] { get }
    var presentedAlertBinding: Binding<PlayersView.PresentedAlert?> { get }

    func mixTeam()

    func color(for player: Player) -> Color
    func createPlayer(name: String, image: ImageIdentifier)
    func editPlayer(_ player: Player)
    func deletePlayer(in team: Team, at offsets: IndexSet)
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

    func color(for player: Player) -> Color {
        guard let team = teams.first(where: { $0.players.contains(player) }) else {
            return .gray
        }
        return team.colorIdentifier.color
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

    func deletePlayer(in team: Team, at offsets: IndexSet) {
        guard let index = teams.firstIndex(of: team) else { return }
        teamsStore.teams[index].players.remove(atOffsets: offsets)
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
        delayPlayersColorReset()
    }

    private func hasLessPlayer(teamA a: Team, teamB b: Team) -> Bool {
        return a.players.count < b.players.count
    }

    private func delayPlayersColorReset() {
        // We need to delay the Player Id reset. Otherwise there will no row animations
        // on the table. And if we don't reset players id, color won't change.
        DispatchQueue.main.asyncAfter(deadline: .now() + PlayersView.playersColorResetDelay) {
            self.teamsStore.teams = self.teams.map({
                var team = $0
                team.players = $0.players.map { Player(name: $0.name, imageIdentifier: $0.imageIdentifier) }
                return team
            })
        }
    }
}
