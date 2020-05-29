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

extension PlayersViewModel {
    private func randomizeTeam() {
        let players = teams.flatMap(\.players)
        guard players.count > 0 else { return }
        let availableTeams = teams.filter { $0 != teams.first }
        guard availableTeams.count > 1 else { return }

        teams.forEach { $0.players = [] }

        players.shuffled().forEach {
            availableTeams.sorted(by: hasLessPlayer).first?.players.append($0)
        }
        teams.first?.players = []
        objectWillChange.send()
    }

    private func hasLessPlayer(teamA a: Team, teamB b: Team) -> Bool {
        return a.players.count < b.players.count
    }
}
