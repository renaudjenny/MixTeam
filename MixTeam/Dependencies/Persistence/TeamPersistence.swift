import AsyncAlgorithms
import Foundation
import IdentifiedCollections

private struct Persistence {
    private let teamFileName = "MixTeamTeamV2_0_0"

    var teams = AsyncThrowingChannel<IdentifiedArrayOf<Team.State>, Error>()

    init() {
        Task { [self] in
            guard
                let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
                let data = try? Data(contentsOf: url.appendingPathComponent(teamFileName, conformingTo: .json))
            else {
                await teams.send(.example)
                return
            }

            do {
                await teams.send(try JSONDecoder().decode(IdentifiedArrayOf<Team.State>.self, from: data))
            } catch {
                await teams.fail(error)
            }
        }
    }

    func load() async throws -> IdentifiedArrayOf<Team.State> {
        for try await teams in teams.prefix(1) {
            return teams
        }
        return []
    }

    func save(_ states: IdentifiedArrayOf<Team.State>) async throws {
        await teams.send(states)
        let data = try JSONEncoder().encode(states)
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw PersistenceError.cannotGetDocumentDirectoryWithUserDomainMask }
        try data.write(to: url.appendingPathComponent(teamFileName, conformingTo: .json))
    }
}

struct TeamPersistence {
    private static let persistence = Persistence()

    var teams: () -> AsyncThrowingChannel<IdentifiedArrayOf<Team.State>, Error> = { persistence.teams }
    var load: () async throws -> IdentifiedArrayOf<Team.State> = persistence.load
    var save: (IdentifiedArrayOf<Team.State>) async throws -> Void = persistence.save
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
