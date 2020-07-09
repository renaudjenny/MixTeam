import SwiftUI

protocol MixTeamLogic: PlayersLogic {
    var presentedAlertBinding: Binding<PlayersView.PresentedAlert?> { get }

    func mixTeam()
}

extension MixTeamLogic {
    func mixTeam() {
        guard teams.count > 2 else {
            presentedAlertBinding.wrappedValue = .notEnoughTeams
            return
        }

        randomizeTeam()
    }

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
