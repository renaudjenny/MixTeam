import Foundation
import IdentifiedCollections

struct TeamPersistence {
    private static var cache: IdentifiedArrayOf<Team.State>?
    private static let teamFileName = "MixTeamTeamV2_0_0"

    var load: () async throws -> IdentifiedArrayOf<Team.State> = {
        if let cache { return cache }
        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let data = try? Data(contentsOf: url.appendingPathComponent(teamFileName, conformingTo: .json))
        else { return .example }
        return try JSONDecoder().decode(IdentifiedArrayOf<Team.State>.self, from: data)
    }
    var save: (IdentifiedArrayOf<Team.State>) async throws -> Void = { teams in
        cache = teams
        let data = try JSONEncoder().encode(teams)
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw PersistenceError.cannotGetDocumentDirectoryWithUserDomainMask }
        try data.write(to: url.appendingPathComponent(teamFileName, conformingTo: .json))
    }
}

extension IdentifiedArrayOf<Team.State> {
    static var example: Self {
        guard let koalaTeamId = UUID(uuidString: "00E9D827-9FAD-4686-83F2-FAD24D2531A2"),
              let purpleElephantId = UUID(uuidString: "98DBAF6C-685D-461F-9F81-E5E1E003B9AA"),
              let blueLionId = UUID(uuidString: "6634515C-19C9-47DF-8B2B-036736F9AEA9"),
              let jackID = UUID(uuidString: "34BC8929-C2F6-42D5-8131-8F048CE649A6")
        else { fatalError("Cannot generate UUID from a defined UUID String") }

        return [
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
    }
}
