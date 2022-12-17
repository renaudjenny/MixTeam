import Combine
import Foundation
import IdentifiedCollections

private final class Persistence {
    private let teamFileName = "MixTeamTeamV2_0_0"

    @Published var teams: IdentifiedArrayOf<Team.State>?

    func load() async throws -> IdentifiedArrayOf<Team.State> {
        if let teams { return teams }
        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let data = try? Data(contentsOf: url.appendingPathComponent(teamFileName, conformingTo: .json))
        else { return .example }

        return try JSONDecoder().decode(IdentifiedArrayOf<Team.State>.self, from: data)
    }

    func save(_ states: IdentifiedArrayOf<Team.State>) async throws {
        teams = states
        let data = try JSONEncoder().encode(states)
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw PersistenceError.cannotGetDocumentDirectoryWithUserDomainMask }
        try data.write(to: url.appendingPathComponent(teamFileName, conformingTo: .json))
    }

    func updateOrAppend(state: Team.State) async throws {
        var states = try await load()
        states.updateOrAppend(state)
        try await save(states)
    }
    func remove(state: Team.State) async throws {
        var states = try await load()
        states.remove(state)
        try await save(states)
    }
}

struct TeamPersistence {
    private static var persistence = Persistence()

    var publisher: () -> AnyPublisher<IdentifiedArrayOf<Team.State>, Never> = {
        persistence.$teams.compactMap { $0 }.eraseToAnyPublisher()
    }
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

        let playersExample: IdentifiedArrayOf<Player.State> = .example
        let players = IdentifiedArrayOf<Player.State>(uniqueElements: playersExample.suffix(1).map {
            var last = $0
            last.color = .strawberry
            return last
        })

        return [
            Team.State(
                id: koalaTeamId,
                name: "Strawberry Koala",
                color: .strawberry,
                image: .koala,
                playerIDs: players.map(\.id),
                players: .loaded(players)
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
