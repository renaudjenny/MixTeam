import Combine
import Foundation
import IdentifiedCollections

private final class Persistence {
    private let playerFileName = "MixTeamPlayerV2_0_0"

    @Published var players: IdentifiedArrayOf<Player.State>?

    func load() async throws -> IdentifiedArrayOf<Player.State> {
        if let players { return players }
        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let data = try? Data(contentsOf: url.appendingPathComponent(playerFileName, conformingTo: .json))
        else { return .example }

        return try JSONDecoder().decode(IdentifiedArrayOf<Player.State>.self, from: data)
    }

    func save(_ states: IdentifiedArrayOf<Player.State>) async throws {
        players = states
        let data = try JSONEncoder().encode(states)
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw PersistenceError.cannotGetDocumentDirectoryWithUserDomainMask }
        try data.write(to: url.appendingPathComponent(playerFileName, conformingTo: .json))
    }

    func updateOrAppend(state: Player.State) async throws {
        var states = try await load()
        states.updateOrAppend(state)
        try await save(states)
    }
    func remove(id: Player.State.ID) async throws {
        var states = try await load()
        states.remove(id: id)
        try await save(states)
    }
}

struct PlayerPersistence {
    private static var persistence = Persistence()

    var publisher: () -> AnyPublisher<IdentifiedArrayOf<Player.State>, Never> = {
        persistence.$players.compactMap { $0 }.eraseToAnyPublisher()
    }
    var load: () async throws -> IdentifiedArrayOf<Player.State> = { try await persistence.load() }
    var save: (IdentifiedArrayOf<Player.State>) async throws -> Void = { try await persistence.save($0) }
    var updateOrAppend: (Player.State) async throws -> Void = { try await persistence.updateOrAppend(state: $0) }
    var remove: (Player.State.ID) async throws -> Void = { try await persistence.remove(id: $0) }
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
