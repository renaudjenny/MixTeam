import Foundation

struct StandingPersistence {
    private static var cache: Standing.State?
    private static let standingFileName = "MixTeamStandingV2_0_0"

    var load: () async throws -> Standing.State = {
        if let cache { return cache }
        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let data = try? Data(contentsOf: url.appendingPathComponent(standingFileName, conformingTo: .json))
        else { return .example }
        return try JSONDecoder().decode(Standing.State.self, from: data)
    }
    var save: (Standing.State) async throws -> Void = { standing in
        cache = standing
        let data = try JSONEncoder().encode(standing)
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw PersistenceError.cannotGetDocumentDirectoryWithUserDomainMask }
        try data.write(to: url.appendingPathComponent(standingFileName, conformingTo: .json))
    }
}

extension Standing.State {
    static var example: Self {
        guard let ameliaID = UUID(uuidString: "F336E7F8-78AC-439B-8E32-202DE58CFAC2"),
              let joseID = UUID(uuidString: "C0F0266B-FFF1-47B0-8A2C-CC90BC36CF15")
        else { fatalError("Cannot generate UUID from a defined UUID String") }

        return Standing.State(players: [
            Player.State(id: ameliaID, name: "Amelia", image: .amelie, color: .aluminium, isStanding: true),
            Player.State(id: joseID, name: "José", image: .santa, color: .aluminium, isStanding: true),
        ])
    }
}
