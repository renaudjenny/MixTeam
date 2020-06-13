import SwiftUI
import Combine

final class TeamsViewModel: ObservableObject {
    @Published var teams: [Team] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        teams = Array(Team.loadList().dropFirst())
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

    func deleteTeam(at index: IndexSet) {
        index.forEach({ teams[$0].delete() })
    }
}
