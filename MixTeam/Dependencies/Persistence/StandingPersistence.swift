import Combine
import Foundation

private final class Persistence {
    private let standingFileName = "MixTeamStandingV2_0_0"

    @Published var standing: Standing.State?

    func load() async throws -> Standing.State {
        if let standing { return standing }
        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let data = try? Data(contentsOf: url.appendingPathComponent(standingFileName, conformingTo: .json))
        else { return .example }

        return try JSONDecoder().decode(Standing.State.self, from: data)
    }

    func save(_ state: Standing.State) async throws {
        standing = state
        let data = try JSONEncoder().encode(state)
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw PersistenceError.cannotGetDocumentDirectoryWithUserDomainMask }
        try data.write(to: url.appendingPathComponent(standingFileName, conformingTo: .json))
    }
}

struct StandingPersistence {
    private static var persistence = Persistence()

    var load: () async throws -> Standing.State = { try await persistence.load() }
    var save: (Standing.State) async throws -> Void = { try await persistence.save($0) }
}

extension Standing.State {
    static var example: Self {
        guard let ameliaID = UUID(uuidString: "F336E7F8-78AC-439B-8E32-202DE58CFAC2"),
              let joseID = UUID(uuidString: "C0F0266B-FFF1-47B0-8A2C-CC90BC36CF15")
        else { fatalError("Cannot generate UUID from a defined UUID String") }

        return Self(
            playerIDs: [ameliaID, joseID],
            players: .loaded([
                Player.State(id: ameliaID, name: "Amelia", image: .amelie, color: .aluminium, isStanding: true),
                Player.State(id: joseID, name: "José", image: .santa, color: .aluminium, isStanding: true),
            ])
        )
    }
}
