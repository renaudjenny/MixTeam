import Combine
import Dependencies
import Foundation
import IdentifiedCollections
import XCTestDynamicOverlay

private final class Persistence {
    private let teamFileName = "MixTeamTeamV3_1_0"

    @Dependency(\.playerPersistence) var player

    let subject = PassthroughSubject<IdentifiedArrayOf<Team.State>, Error>()
    var value: IdentifiedArrayOf<Team.State> {
        didSet { Task { try await persist(value) } }
    }

    init() throws {
        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let data = try? Data(contentsOf: url.appendingPathComponent(teamFileName, conformingTo: .json))
        else {
            value = .example
            subject.send(value)
            return
        }

        let decodedValue = try JSONDecoder().decode(IdentifiedArrayOf<Team.State>.self, from: data)
        value = decodedValue
        subject.send(value)
    }

    func save(_ states: IdentifiedArrayOf<Team.State>) async throws {
        value = states
        subject.send(value)
    }

    private func persist(_ states: IdentifiedArrayOf<Team.State>) async throws {
        let data = try JSONEncoder().encode(states)
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw PersistenceError.cannotGetDocumentDirectoryWithUserDomainMask }
        try data.write(to: url.appendingPathComponent(teamFileName, conformingTo: .json))
    }

    func inflated(value: IdentifiedArrayOf<Team.State>) async throws -> IdentifiedArrayOf<Team.State> {
        let players = try await player.load()

        return IdentifiedArrayOf(uniqueElements: value.compactMap {
            guard var team = value[id: $0.id] else { return nil }
            team.players = IdentifiedArrayOf(uniqueElements: team.players.compactMap {
                var player = players[id: $0.id]
                player?.color = team.color
                return  player
            })
            return team
        })
    }

    func updateOrAppend(state: Team.State) async throws {
        value.updateOrAppend(state)
        subject.send(try await inflated(value: value))
    }
    func update(values: IdentifiedArrayOf<Team.State>) async throws {
        for value in values {
            self.value.updateOrAppend(value)
        }
        subject.send(try await inflated(value: value))
    }
    func remove(state: Team.State) async throws {
        value.remove(state)
        subject.send(try await inflated(value: value))
    }
}

struct TeamPersistence {
    var publisher: () -> AsyncThrowingPublisher<AnyPublisher<IdentifiedArrayOf<Team.State>, Error>>
    var load: () async throws -> IdentifiedArrayOf<Team.State>
    var save: (IdentifiedArrayOf<Team.State>) async throws -> Void
    var updateOrAppend: (Team.State) async throws -> Void
    var updateValues: (IdentifiedArrayOf<Team.State>) async throws -> Void
    var remove: (Team.State) async throws -> Void
}

extension TeamPersistence {
    static let live =  {
        do {
            let persistence = try Persistence()
            return Self(
                publisher: { persistence.subject.eraseToAnyPublisher().values },
                load: { try await persistence.inflated(value: persistence.value) },
                save: { try await persistence.save($0) },
                updateOrAppend: { try await persistence.updateOrAppend(state: $0) },
                updateValues: { try await persistence.update(values: $0) },
                remove: { try await persistence.remove(state: $0) }
            )
        } catch {
            return Self(
                publisher: { Fail(error: error).eraseToAnyPublisher().values },
                load: { throw error },
                save: { _ in throw error },
                updateOrAppend: { _ in throw error },
                updateValues: { _ in throw error },
                remove: { _ in throw error }
            )
        }
    }()
    static let test = Self(
        publisher: unimplemented("TeamPersistence.publisher"),
        load: unimplemented("TeamPersistence.load"),
        save: unimplemented("TeamPersistence.save"),
        updateOrAppend: unimplemented("TeamPersistence.updateOrAppend"),
        updateValues: unimplemented("TeamPersistence.updateValues"),
        remove: unimplemented("TeamPersistence.remove")
    )
    static let preview = Self(
        publisher: { Result.Publisher(.example).eraseToAnyPublisher().values },
        load: { .example },
        save: { _ in print("TeamPersistence.save called") },
        updateOrAppend: { _ in print("TeamPersistence.updateOrAppend called") },
        updateValues: { _ in print("TeamPersistence.updateValues called") },
        remove: { _ in print("TeamPersistence.remove called") }
    )
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

private enum TeamPersistenceDependencyKey: DependencyKey {
    static let liveValue = TeamPersistence.live
    static let testValue = TeamPersistence.test
    static let previewValue = TeamPersistence.preview
}

extension DependencyValues {
    var teamPersistence: TeamPersistence {
        get { self[TeamPersistenceDependencyKey.self] }
        set { self[TeamPersistenceDependencyKey.self] = newValue }
    }
}
