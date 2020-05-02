import SwiftUI

final class PlayersViewModel: ObservableObject {
    @Published var teams: [Team] = []

    init() {
        teams = Team.loadList()
        teams.first?.name = NSLocalizedString("Players standing for a team", comment: "")
        teams.first?.color = .gray
    }
}
