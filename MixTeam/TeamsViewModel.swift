import SwiftUI

final class TeamsViewModel: ObservableObject {
    @Published var teams: [Team] = []

    init() {
        teams = Array(Team.loadList().dropFirst())
    }
}
