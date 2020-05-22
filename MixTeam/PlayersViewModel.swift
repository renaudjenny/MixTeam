import SwiftUI

final class PlayersViewModel: ObservableObject {
    @Published var teams: [Team] = []
    @Published var presentedAlert: PlayersView.PresentedAlert? = nil

    init() {
        teams = Team.loadList()
        teams.first?.name = NSLocalizedString("Players standing for a team", comment: "")
        teams.first?.color = .gray
    }

    func mixTeam() {
        guard teams.count > 2 else {
            presentedAlert = .notEnoughTeams
            return
        }

        randomizeTeam()
    }
}

// TODO: Old code. Refactor and simplify this
extension PlayersViewModel {
    private func randomizeTeam() {
        var teamsHandicap: [Team: Int] = Dictionary(teams
            .map({ team -> (Team, Int) in
                let handicapSum = team.players
                    .map(\.handicap)
                    .reduce(0, +)
                return (team, handicapSum)
            }), uniquingKeysWith: { $1 })

        let playersTotalHandicap = teamsHandicap.values.reduce(0, +)

        debug()
        for team in teams {
            for player in team.players {
                let toTeam = pseudoRandomTeam(teamsHandicap: teamsHandicap, playersTotalHandicap: playersTotalHandicap)
                teamsHandicap[team]! -= player.handicap
                teamsHandicap[toTeam]! += player.handicap
                if team != toTeam {
                    self.move(player: player, from: team, to: toTeam)
                }
            }
        }
        debug()
    }

    private func move(player: Player, from fromTeam: Team, to toTeam: Team) {
        guard let originPlayerIndex = fromTeam.players.firstIndex(where: { $0.id == player.id }) else {
            return
        }

        toTeam.players.append(player)
        fromTeam.players.remove(at: originPlayerIndex)

        // deferAutoSave()
    }

    private func pseudoRandomTeam(teamsHandicap: [Team: Int], playersTotalHandicap: Int) -> Team {
        // First, add a player in each team if there is no one yet
        let teamsWithoutPlayers = teams
            .filter { $0 != teams.first }
            .filter { teamsHandicap[$0]! <= 0 }

        if teamsWithoutPlayers.count > 0 {
            let randomIndex = Int(arc4random_uniform(UInt32(teamsWithoutPlayers.count)))
            return teamsWithoutPlayers[randomIndex]
        }

        let handicapAverage = playersTotalHandicap / (teams.count - 1)

        // Choose only teams that total handicap is under the average
        let unbalancedTeams = teams
            .filter { $0 != teams.first }
            .filter { teamsHandicap[$0]! < handicapAverage }

        let randomIndex = Int.random(in: 0..<unbalancedTeams.count)
        return unbalancedTeams[randomIndex]
    }

    private func remove(team: Team) {
        guard let firstTeam = teams.first,
            let teamToDeleteIndex = teams.firstIndex(where: { $0 == team }) else {
                fatalError("Cannot retrieve first team or team to delete index")
        }

        let teamToDelete = teams[teamToDeleteIndex]

        teamToDelete.players.forEach { (player) in
            self.move(player: player, from: teamToDelete, to: firstTeam)
        }

        // TODO: Teams need to be a binding/state
        // teams.remove(at: teamToDeleteIndex)
    }

    private func debug() {
        print(teams
            .map { ($0.name, $0.players.map(\.name)) }
        )
    }
}
