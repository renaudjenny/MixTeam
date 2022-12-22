import AsyncAlgorithms
import Foundation
import IdentifiedCollections

private struct Persistence {
    private let teamFileName = "MixTeamTeamV2_0_0"

    let channel = AsyncChannel<IdentifiedArrayOf<Team.State>>()
    var value: IdentifiedArrayOf<Team.State>? {
        didSet {
            if let value {
                Task { [channel, value] in await channel.send(value) }
            }
        }
    }

    mutating func load() async throws -> IdentifiedArrayOf<Team.State> {
        if let value { return value }
        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let data = try? Data(contentsOf: url.appendingPathComponent(teamFileName, conformingTo: .json))
        else { return .example }

        let decodedValue = try JSONDecoder().decode(IdentifiedArrayOf<Team.State>.self, from: data)
        value = decodedValue
        return decodedValue
    }

    mutating func save(_ states: IdentifiedArrayOf<Team.State>) async throws {
        value = states
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

    var channel: () -> AsyncChannel<IdentifiedArrayOf<Team.State>> = { persistence.channel }
    var load: () async throws -> IdentifiedArrayOf<Team.State> = { try await persistence.load() }
    var save: (IdentifiedArrayOf<Team.State>) async throws -> Void = { try await persistence.save($0) }
    var updateOrAppend: (Team.State) async throws -> Void = { try await persistence.updateOrAppend(state: $0) }
    var remove: (Team.State) async throws -> Void = { try await persistence.remove(state: $0) }
}

extension Team.State: Codable {
    enum CodingKeys: CodingKey {
        case id
        case name
        case color
        case image
        case playerIDs
        case isArchived
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let playerIDs = try container.decode([Player.State.ID].self, forKey: .playerIDs)
        players = IdentifiedArrayOf(uniqueElements: playerIDs.map { Player.State(id: $0) })
        id = try container.decode(Player.State.ID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        color = try container.decode(MTColor.self, forKey: .color)
        image = try container.decode(MTImage.self, forKey: .image)
        isArchived = try container.decode(Bool.self, forKey: .isArchived)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(players.map(\.id), forKey: .playerIDs)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(color, forKey: .color)
        try container.encode(image, forKey: .image)
        try container.encode(isArchived, forKey: .isArchived)
    }
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
                players: players
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
