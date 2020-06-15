import SwiftUI
import Combine

final class TeamsViewModel: ObservableObject {
    @Published var teams: [Team] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        teams = Team.loadList()
        NotificationCenter.default.publisher(for: .TeamsUpdated)
            .compactMap({ $0.object as? [Team] })
            .assign(to: \.teams, on: self)
            .store(in: &cancellables)
    }

    func createTeam(name: String, image: ImageIdentifier, color: ColorIdentifier) {
        let team = Team(
            name: name,
            color: UXColor(rawValue: color.rawValue) ?? .red,
            image: image.appImage
        )
        team.save()
    }

    func deleteTeam(atOffsets offsets: IndexSet) {
        // As the real first team is not displayed. The real index is offset + 1
        let index = (offsets.first ?? 0) + 1
        let playersInDeletedTeam = teams[index].players
        teams[0].players.append(contentsOf: playersInDeletedTeam)
        teams[0].update()

        teams[index].delete()
    }

    func teamBinding(for team: Team) -> Binding<Team>? {
        guard let teamIndex = teams.firstIndex(of: team) else {
            return nil
        }
        return Binding<Team>(
            get: { self.teams[teamIndex] },
            set: { self.teams[teamIndex] = $0 }
        )
    }
}
