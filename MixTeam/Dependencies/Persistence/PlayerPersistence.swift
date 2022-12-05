import Foundation
import IdentifiedCollections

struct PlayerPersistence {
    private static var cache: IdentifiedArrayOf<Player.State>?
    private static let playerFileName = "MixTeamPlayerV2_0_0"

    var load: () async throws -> IdentifiedArrayOf<Player.State> = {
        if let cache { return cache }
        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let data = try? Data(contentsOf: url.appendingPathComponent(playerFileName, conformingTo: .json))
        else { return .example }
        return try JSONDecoder().decode(IdentifiedArrayOf<Player.State>.self, from: data)
    }
    var save: (IdentifiedArrayOf<Player.State>) async throws -> Void = { players in
        cache = players
        let data = try JSONEncoder().encode(players)
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw PersistenceError.cannotGetDocumentDirectoryWithUserDomainMask }
        try data.write(to: url.appendingPathComponent(playerFileName, conformingTo: .json))
    }
}

extension IdentifiedArrayOf<Player.State> {
    static var example: Self {
        guard let ameliaID = UUID(uuidString: "F336E7F8-78AC-439B-8E32-202DE58CFAC2"),
              let joseID = UUID(uuidString: "C0F0266B-FFF1-47B0-8A2C-CC90BC36CF15"),
              let jackID = UUID(uuidString: "34BC8929-C2F6-42D5-8131-8F048CE649A6")
        else { fatalError("Cannot generate UUID from a defined UUID String") }

        return [
            Player.State(id: ameliaID, name: "Amelia", image: .girl),
            Player.State(id: joseID, name: "José", image: .santa),
            Player.State(id: jackID, name: "Jack", image: .jack),
        ]
    }
}
