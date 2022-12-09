import AsyncAlgorithms
import Foundation
import IdentifiedCollections

private struct Persistence {
    private let teamFileName = "MixTeamTeamV2_0_0"

    var channel = AsyncThrowingChannel<IdentifiedArrayOf<Team.State>, Error>()
    private var last: IdentifiedArrayOf<Team.State>?

    init() {
        Task { [self] in
            guard
                let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
                let data = try? Data(contentsOf: url.appendingPathComponent(teamFileName, conformingTo: .json))
            else {
                await channel.send(.example)
                return
            }

            do {
                await channel.send(try JSONDecoder().decode(IdentifiedArrayOf<Team.State>.self, from: data))
            } catch {
                await channel.fail(error)
            }
        }
    }

    mutating func load() async throws -> IdentifiedArrayOf<Team.State> {
        if let last { return last }
        for try await teams in channel.prefix(1) {
            last = teams
        }
        return last ?? []
    }

    mutating func save(_ states: IdentifiedArrayOf<Team.State>) async throws {
        last = states
        await channel.send(states)
        let data = try JSONEncoder().encode(states)
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw PersistenceError.cannotGetDocumentDirectoryWithUserDomainMask }
        try data.write(to: url.appendingPathComponent(teamFileName, conformingTo: .json))
    }
}

struct TeamPersistence {
    private static var persistence = Persistence()

    var channel: () -> AsyncThrowingChannel<IdentifiedArrayOf<Team.State>, Error> = { persistence.channel }
    var load: () async throws -> IdentifiedArrayOf<Team.State> = { try await persistence.load() }
    var save: (IdentifiedArrayOf<Team.State>) async throws -> Void = { try await persistence.save($0) }
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
