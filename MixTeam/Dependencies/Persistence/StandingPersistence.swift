import Foundation

private struct Persistence {
    private let standingFileName = "MixTeamStandingV2_0_0"

    var saveHandler: ((Standing.Persistence) -> Void)?
    private var cache: Standing.Persistence?

    func load() async throws -> Standing.Persistence {
        if let cache { return cache }
        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let data = try? Data(contentsOf: url.appendingPathComponent(standingFileName, conformingTo: .json))
        else { return .example }

        return try JSONDecoder().decode(Standing.Persistence.self, from: data)
    }

    mutating func save(_ state: Standing.Persistence) async throws {
        cache = state
        saveHandler?(state)
        let data = try JSONEncoder().encode(state)
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw PersistenceError.cannotGetDocumentDirectoryWithUserDomainMask }
        try data.write(to: url.appendingPathComponent(standingFileName, conformingTo: .json))
    }
}

struct StandingPersistence {
    private static var persistence = Persistence()
    private static var stream: AsyncThrowingStream<Standing.Persistence, Error> {
        AsyncThrowingStream { continuation in persistence.saveHandler = { continuation.yield($0) } }
    }

    var stream: () -> AsyncThrowingStream<Standing.Persistence, Error> = { stream }
    var load: () async throws -> Standing.Persistence = { try await persistence.load() }
    var save: (Standing.Persistence) async throws -> Void = { try await persistence.save($0) }
}

extension Standing.State {
    static var example: Self {
        guard let ameliaID = UUID(uuidString: "F336E7F8-78AC-439B-8E32-202DE58CFAC2"),
              let joseID = UUID(uuidString: "C0F0266B-FFF1-47B0-8A2C-CC90BC36CF15")
        else { fatalError("Cannot generate UUID from a defined UUID String") }

        return .loaded(players: [
            Player.State(id: ameliaID, name: "Amelia", image: .amelie, color: .aluminium, isStanding: true),
            Player.State(id: joseID, name: "José", image: .santa, color: .aluminium, isStanding: true),
        ])
    }
}

extension Standing.Persistence {
    static var example: Self {
        guard case let .loaded(players) = Standing.State.example else { return Self(playerIDs: []) }
        return Self(playerIDs: players.map(\.id))
    }
}
