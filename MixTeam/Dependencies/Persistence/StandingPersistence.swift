import AsyncAlgorithms
import Foundation

private struct Persistence {
    private let standingFileName = "MixTeamStandingV2_0_0"

    let channel = AsyncChannel<Standing.State>()
    var value: Standing.State? {
        didSet {
            if let value {
                Task { [channel, value] in await channel.send(value) }
            }
        }
    }

    mutating func load() async throws -> Standing.State {
        if let value { return value }
        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let data = try? Data(contentsOf: url.appendingPathComponent(standingFileName, conformingTo: .json))
        else { return .example }

        return try JSONDecoder().decode(Standing.State.self, from: data)
    }

    mutating func save(_ state: Standing.State) async throws {
        value = state
        let data = try JSONEncoder().encode(state)
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw PersistenceError.cannotGetDocumentDirectoryWithUserDomainMask }
        try data.write(to: url.appendingPathComponent(standingFileName, conformingTo: .json))
    }
}

struct StandingPersistence {
    private static var persistence = Persistence()

    var channel: () -> AsyncChannel<Standing.State> = { persistence.channel }
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
