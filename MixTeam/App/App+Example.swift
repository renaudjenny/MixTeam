import ComposableArchitecture
import Foundation

extension App.State {
    static var example: Self {
        guard let koalaTeamId = UUID(uuidString: "00E9D827-9FAD-4686-83F2-FAD24D2531A2"),
              let purpleElephantId = UUID(uuidString: "98DBAF6C-685D-461F-9F81-E5E1E003B9AA"),
              let blueLionId = UUID(uuidString: "6634515C-19C9-47DF-8B2B-036736F9AEA9"),
              let ameliaID = UUID(uuidString: "F336E7F8-78AC-439B-8E32-202DE58CFAC2"),
              let joseID = UUID(uuidString: "C0F0266B-FFF1-47B0-8A2C-CC90BC36CF15"),
              let jackID = UUID(uuidString: "34BC8929-C2F6-42D5-8131-8F048CE649A6")
        else { fatalError("Cannot generate UUID from a defined UUID String") }

        return App.State(
            standing: Standing.State(players: [
                Player.State(id: ameliaID, name: "Amelia", image: .girl, color: .aluminium, isStanding: true),
                Player.State(id: joseID, name: "José", image: .santa, color: .aluminium, isStanding: true),
            ]),
            teams: [
                Team.State(
                    id: koalaTeamId,
                    name: "Strawberry Koala",
                    color: .strawberry,
                    image: .koala,
                    players: [Player.State(id: jackID, name: "Jack", image: .jack, color: .strawberry)]
                ),
                Team.State(
                    id: purpleElephantId,
                    name: "Lilac Elephant",
                    color: .lilac,
                    image: .elephant
                ),
                Team.State(
                    id: blueLionId,
                    name: "Bluejeans Lion",
                    color: .bluejeans,
                    image: .lion
                ),
            ]
        )
    }
}
