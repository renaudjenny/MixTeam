import AsyncAlgorithms
import Foundation
import IdentifiedCollections

private struct Persistence {
    private let playerFileName = "MixTeamPlayerV2_0_0"

    let channel = AsyncThrowingChannel<IdentifiedArrayOf<Player.State>, Error>()
    private var last: IdentifiedArrayOf<Player.State>?

    init() {
        Task { [self] in
            guard
                let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
                let data = try? Data(contentsOf: url.appendingPathComponent(playerFileName, conformingTo: .json))
            else {
                await channel.send(.example)
                return
            }

            do {
                await channel.send(try JSONDecoder().decode(IdentifiedArrayOf<Player.State>.self, from: data))
            } catch {
                await channel.fail(error)
            }
        }
    }

    mutating func load() async throws -> IdentifiedArrayOf<Player.State> {
        if let last { return last }
        for try await players in channel.prefix(1) {
            last = players
        }
        return last ?? []
    }

    mutating func save(_ states: IdentifiedArrayOf<Player.State>) async throws {
        last = states
        await channel.send(states)
        let data = try JSONEncoder().encode(states)
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw PersistenceError.cannotGetDocumentDirectoryWithUserDomainMask }
        try data.write(to: url.appendingPathComponent(playerFileName, conformingTo: .json))
    }
}

struct PlayerPersistence {
    private static var persistence = Persistence()

    var channel: () -> AsyncThrowingChannel<IdentifiedArrayOf<Player.State>, Error> = { persistence.channel }
    var load: () async throws -> IdentifiedArrayOf<Player.State> = { try await persistence.load() }
    var save: (IdentifiedArrayOf<Player.State>) async throws -> Void = { try await persistence.save($0) }
    var updateOrAppend: (Player.State) async throws -> Void = { player in
        var players = try await persistence.load()
        players.updateOrAppend(player)
        try await persistence.save(players)
    }
    var remove: (Player.State) async throws -> Void = { player in
        var players = try await persistence.load()
        players.remove(player)
        try await persistence.save(players)
    }
}

extension IdentifiedArrayOf<Player.State> {
    static var example: Self {
        guard let ameliaID = UUID(uuidString: "F336E7F8-78AC-439B-8E32-202DE58CFAC2"),
              let joseID = UUID(uuidString: "C0F0266B-FFF1-47B0-8A2C-CC90BC36CF15"),
              let jackID = UUID(uuidString: "34BC8929-C2F6-42D5-8131-8F048CE649A6")
        else { fatalError("Cannot generate UUID from a defined UUID String") }

        return [
            Player.State(id: ameliaID, name: "Amelia", image: .amelie),
            Player.State(id: joseID, name: "José", image: .santa),
            Player.State(id: jackID, name: "Jack", image: .jack),
        ]
    }
}
