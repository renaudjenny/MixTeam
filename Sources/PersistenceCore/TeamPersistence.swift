import Assets
import Combine
import Dependencies
import Foundation
import IdentifiedCollections
import XCTestDynamicOverlay

// TODO: change `(state: Team)` to `(team: Team)`
private final class Persistence {
    private let teamFileName = "MixTeamTeamV3_1_0"

//    @Dependency(\.playerPersistence) var player

    let subject = PassthroughSubject<IdentifiedArrayOf<Team>, Error>()
    var value: IdentifiedArrayOf<Team> {
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

        let decodedValue = try JSONDecoder().decode(IdentifiedArrayOf<Team>.self, from: data)
        value = decodedValue
        subject.send(value)
    }

    func save(_ states: IdentifiedArrayOf<Team>) async throws {
        value = states
        subject.send(value)
    }

    private func persist(_ states: IdentifiedArrayOf<Team>) async throws {
        let data = try JSONEncoder().encode(states)
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw PersistenceError.cannotGetDocumentDirectoryWithUserDomainMask }
        try data.write(to: url.appendingPathComponent(teamFileName, conformingTo: .json))
    }

    func updateOrAppend(state: Team) async throws {
        value.updateOrAppend(state)
        subject.send(value)
    }
    func update(values: IdentifiedArrayOf<Team>) async throws {
        for value in values {
            self.value.updateOrAppend(value)
        }
        subject.send(value)
    }
    func remove(state: Team) async throws {
        value.remove(state)
        subject.send(value)
    }
}

public struct TeamPersistence {
    public var publisher: () -> AsyncThrowingPublisher<AnyPublisher<IdentifiedArrayOf<Team>, Error>>
    public var load: () async throws -> IdentifiedArrayOf<Team>
    public var save: (IdentifiedArrayOf<Team>) async throws -> Void
    public var updateOrAppend: (Team) async throws -> Void
    public var updateValues: (IdentifiedArrayOf<Team>) async throws -> Void
    public var remove: (Team) async throws -> Void
}

extension TeamPersistence {
    static let live =  {
        do {
            let persistence = try Persistence()
            return Self(
                publisher: { persistence.subject.eraseToAnyPublisher().values },
                load: { persistence.value },
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

// TODO: remove the redundancy with `public extension IdentifiedArrayOf<Team.State>`
public extension IdentifiedArrayOf<Team> {
    static var example: Self {
        guard let koalaTeamId = UUID(uuidString: "00E9D827-9FAD-4686-83F2-FAD24D2531A2"),
              let purpleElephantId = UUID(uuidString: "98DBAF6C-685D-461F-9F81-E5E1E003B9AA"),
              let blueLionId = UUID(uuidString: "6634515C-19C9-47DF-8B2B-036736F9AEA9")
        else { fatalError("Cannot generate UUID from a defined UUID String") }

        let playersExample: IdentifiedArrayOf<Player> = .example
        let players = IdentifiedArrayOf<Player>(uniqueElements: playersExample.suffix(1))

        return [
            Team(
                id: koalaTeamId,
                name: "Strawberry Koala",
                color: .strawberry,
                image: .koala,
                playerIDs: players.map(\.id),
                isArchived: false
            ),
            Team(
                id: purpleElephantId,
                name: "Lilac Elephant",
                color: .lilac,
                image: .elephant,
                playerIDs: [],
                isArchived: false
            ),
            Team(
                id: blueLionId,
                name: "Bluejeans Lion",
                color: .bluejeans,
                image: .lion,
                playerIDs: [],
                isArchived: false
            ),
        ]
    }
}

private enum TeamPersistenceDependencyKey: DependencyKey {
    static let liveValue = TeamPersistence.live
    static let testValue = TeamPersistence.test
    static let previewValue = TeamPersistence.preview
}

public extension DependencyValues {
    var teamPersistence: TeamPersistence {
        get { self[TeamPersistenceDependencyKey.self] }
        set { self[TeamPersistenceDependencyKey.self] = newValue }
    }
}
