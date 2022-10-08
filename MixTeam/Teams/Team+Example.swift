import Foundation

extension [Team.State] {
    static var example: Self {
        guard let playersStandingTeamId = UUID(uuidString: "D6C7FA85-8DA0-45B7-8688-3D3390EACF05"),
              let koalaTeamId = UUID(uuidString: "00E9D827-9FAD-4686-83F2-FAD24D2531A2"),
              let purpleElephantId = UUID(uuidString: "98DBAF6C-685D-461F-9F81-E5E1E003B9AA"),
              let blueLionId = UUID(uuidString: "6634515C-19C9-47DF-8B2B-036736F9AEA9"),
              let ameliaID = UUID(uuidString: "F336E7F8-78AC-439B-8E32-202DE58CFAC2"),
              let joseID = UUID(uuidString: "C0F0266B-FFF1-47B0-8A2C-CC90BC36CF15"),
              let jackID = UUID(uuidString: "34BC8929-C2F6-42D5-8131-8F048CE649A6")
        else { fatalError("Cannot generate UUID from a defined UUID String") }

        var playersStandingTeam = Team.State(
            id: playersStandingTeamId,
            name: "Players standing for a team",
            colorIdentifier: .gray, imageIdentifier: .unknown
        )
        playersStandingTeam.players = [
            Player.State(id: ameliaID, name: "Amelia", image: .girl, isInFirstRow: true),
            Player.State(id: joseID, name: "José", image: .santa, isInFirstRow: true),
        ]
        var koalaTeam = Team.State(
            id: koalaTeamId,
            name: "Red Koala",
            colorIdentifier: .red,
            imageIdentifier: .koala
        )
        koalaTeam.players = [Player.State(id: jackID, name: "Jack", image: .jack)]
        return [
            playersStandingTeam,
            koalaTeam,
            Team.State(
                id: purpleElephantId,
                name: "Purple Elephant",
                colorIdentifier: .purple,
                imageIdentifier: .elephant
            ),
            Team.State(
                id: blueLionId,
                name: "Blue Lion",
                colorIdentifier: .blue,
                imageIdentifier: .lion
            ),
        ]
    }
}
