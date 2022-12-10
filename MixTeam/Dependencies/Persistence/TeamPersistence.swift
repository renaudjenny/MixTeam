import Foundation
import IdentifiedCollections

private struct Persistence {
    private let teamFileName = "MixTeamTeamV2_0_0"

    var saveHandler: ((IdentifiedArrayOf<Team.State>) -> Void)?
    private var cache: IdentifiedArrayOf<Team.State>?

    mutating func load() async throws -> IdentifiedArrayOf<Team.State> {
        if let cache { return cache }
        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let data = try? Data(contentsOf: url.appendingPathComponent(teamFileName, conformingTo: .json))
        else { return .example }

        return try JSONDecoder().decode(IdentifiedArrayOf<Team.State>.self, from: data)
    }

    mutating func save(_ states: IdentifiedArrayOf<Team.State>) async throws {
        cache = states
        saveHandler?(states)
        let data = try JSONEncoder().encode(states)
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw PersistenceError.cannotGetDocumentDirectoryWithUserDomainMask }
        try data.write(to: url.appendingPathComponent(teamFileName, conformingTo: .json))
    }

    mutating func updateOrAppend(state: Team.State) async throws {
        var states = try await load()
        states.updateOrAppend(state)
        try await save(states)
    }
    mutating func remove(state: Team.State) async throws {
        var states = try await load()
        states.remove(state)
        try await save(states)
    }
}

struct TeamPersistence {
    private static var persistence = Persistence()
    private static var stream: AsyncThrowingStream<IdentifiedArrayOf<Team.State>, Error> {
        AsyncThrowingStream { continuation in persistence.saveHandler = { continuation.yield($0) } }
    }

    var stream: () -> AsyncThrowingStream<IdentifiedArrayOf<Team.State>, Error> = { stream }
    var load: () async throws -> IdentifiedArrayOf<Team.State> = { try await persistence.load() }
    var save: (IdentifiedArrayOf<Team.State>) async throws -> Void = { try await persistence.save($0) }
    var updateOrAppend: (Team.State) async throws -> Void = { try await persistence.updateOrAppend(state: $0) }
    var remove: (Team.State) async throws -> Void = { try await persistence.remove(state: $0) }
}

extension IdentifiedArrayOf<Team.State> {
    static var example: Self {
        guard let koalaTeamId = UUID(uuidString: "00E9D827-9FAD-4686-83F2-FAD24D2531A2"),
              let purpleElephantId = UUID(uuidString: "98DBAF6C-685D-461F-9F81-E5E1E003B9AA"),
              let blueLionId = UUID(uuidString: "6634515C-19C9-47DF-8B2B-036736F9AEA9")
        else { fatalError("Cannot generate UUID from a defined UUID String") }

        return [
            Team.State(
                id: koalaTeamId,
                name: "Strawberry Koala",
                color: .strawberry,
                image: .koala,
                players: IdentifiedArrayOf<Player.State>.example.last.map { [$0] } ?? []
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
