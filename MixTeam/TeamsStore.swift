import SwiftUI

final class TeamsStore: ObservableObject {
    static let teamsKey = "teams"
    @Published var teams: [Team] {
        didSet { save() }
    }

    init() {
        guard let data = UserDefaults.standard.data(forKey: Self.teamsKey) else {
            teams = .exampleTeam
            return
        }

        let savedTeams = try? JSONDecoder().decode([Team].self, from: data)
        teams = savedTeams ?? .exampleTeam
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(teams) else { return }
        UserDefaults.standard.set(data, forKey: Self.teamsKey)
    }
}

extension Array where Element == Team {
    static let exampleTeam: Self = {
        guard let playersStandingTeamId = UUID(uuidString: "D6C7FA85-8DA0-45B7-8688-3D3390EACF05"),
              let koalaTeamId = UUID(uuidString: "00E9D827-9FAD-4686-83F2-FAD24D2531A2"),
              let purpleElephantId = UUID(uuidString: "98DBAF6C-685D-461F-9F81-E5E1E003B9AA"),
              let blueLionId = UUID(uuidString: "6634515C-19C9-47DF-8B2B-036736F9AEA9")
        else { fatalError("Cannot generate UUID from a defined UUID String") }

        var playersStandingTeam = Team(
            id: playersStandingTeamId,
            name: "Players standing for a team",
            colorIdentifier: .gray, imageIdentifier: .unknown
        )
        playersStandingTeam.players = [
            Player(name: "Amelia", imageIdentifier: .girl),
            Player(name: "José", imageIdentifier: .santa),
        ]
        var koalaTeam = Team(
            id: koalaTeamId,
            name: "Red Koala",
            colorIdentifier: .red,
            imageIdentifier: .koala
        )
        koalaTeam.players = [Player(name: "Jack", imageIdentifier: .jack)]
        return [
            playersStandingTeam,
            koalaTeam,
            Team(
                id: purpleElephantId,
                name: "Purple Elephant",
                colorIdentifier: .purple,
                imageIdentifier: .elephant
            ),
            Team(
                id: blueLionId,
                name: "Blue Lion",
                colorIdentifier: .blue,
                imageIdentifier: .lion
            ),
        ]
    }()
}
