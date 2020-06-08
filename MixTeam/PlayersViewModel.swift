import SwiftUI

final class PlayersViewModel: ObservableObject {
    @Published var teams: [Team] = []
    @Published var presentedAlert: PlayersView.PresentedAlert? = nil

    init() {
        teams = Team.loadList()
        guard teams.count > 0 else { return }
        teams[0].name = NSLocalizedString("Players standing for a team", comment: "")
        teams[0].color = .gray
    }

    func mixTeam() {
        guard teams.count > 2 else {
            presentedAlert = .notEnoughTeams
            return
        }

        randomizeTeam()
    }

    func deletePlayer(in team: Team, at offsets: IndexSet) {
        guard let index = teams.firstIndex(of: team) else { return }
        teams[index].players.remove(atOffsets: offsets)
        updateTeams()
    }

    func color(for player: Player) -> Color {
        guard let team = teams.first(where: { $0.players.contains(player) }) else {
            return .gray
        }
        return Color(team.color.color)
    }

    func updateTeams() {
        Team.save(teams: teams)
        objectWillChange.send()
    }

    func playerBinding(for player: Player) -> Binding<Player>? {
        guard let teamIndex = teams.firstIndex(where: { $0.players.contains(player) }),
            let playerIndex = teams[teamIndex].players.firstIndex(of: player) else {
            return nil
        }
        return Binding<Player>(
            get: { self.teams[teamIndex].players[playerIndex] },
            set: { self.teams[teamIndex].players[playerIndex] = $0 }
        )
    }
}

extension PlayersViewModel {
    private func randomizeTeam() {
        let players = teams.flatMap(\.players)
        guard players.count > 0 else { return }
        guard teams.filter({ $0 != teams.first }).count > 1 else { return }

        teams = teams.map({
            var newTeam = $0
            newTeam.players = []
            return newTeam
        })

        teams = players.shuffled().reduce(teams) { teams, player in
            var teams = teams
            let availableTeams = teams.filter { $0 != teams.first }
            guard let lessPlayerTeam = availableTeams.sorted(by: hasLessPlayer).first,
                let teamIndex = teams.firstIndex(of: lessPlayerTeam) else { return teams }
            teams[teamIndex].players += [player]
            return teams
        }
        updateTeams()
    }

    private func hasLessPlayer(teamA a: Team, teamB b: Team) -> Bool {
        return a.players.count < b.players.count
    }
}
