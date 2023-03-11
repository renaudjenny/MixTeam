import Assets
import Combine
import Dependencies
import Foundation
import IdentifiedCollections
import Models
import XCTestDynamicOverlay

private final class Persistence {
    private let teamFileName = "MixTeamTeamV3_1_0"

    let subject = PassthroughSubject<IdentifiedArrayOf<PersistedTeam>, Error>()
    var value: IdentifiedArrayOf<PersistedTeam> {
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

        let decodedValue = try JSONDecoder().decode(IdentifiedArrayOf<PersistedTeam>.self, from: data)
        value = decodedValue
        subject.send(value)
    }

    func save(_ teams: IdentifiedArrayOf<PersistedTeam>) async throws {
        value = teams
        subject.send(value)
    }

    private func persist(_ teams: IdentifiedArrayOf<PersistedTeam>) async throws {
        let data = try JSONEncoder().encode(teams)
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw PersistenceError.cannotGetDocumentDirectoryWithUserDomainMask }
        try data.write(to: url.appendingPathComponent(teamFileName, conformingTo: .json))
    }

    func updateOrAppend(team: PersistedTeam) async throws {
        value.updateOrAppend(team)
        subject.send(value)
    }
    func update(values: IdentifiedArrayOf<PersistedTeam>) async throws {
        for value in values {
            self.value.updateOrAppend(value)
        }
        subject.send(value)
    }
    func remove(team: PersistedTeam) async throws {
        value.remove(team)
        subject.send(value)
    }
}

public struct TeamPersistence {
    public var publisher: () -> AsyncThrowingPublisher<AnyPublisher<IdentifiedArrayOf<PersistedTeam>, Error>>
    public var load: () async throws -> IdentifiedArrayOf<PersistedTeam>
    public var save: (IdentifiedArrayOf<PersistedTeam>) async throws -> Void
    public var updateOrAppend: (PersistedTeam) async throws -> Void
    public var updateValues: (IdentifiedArrayOf<PersistedTeam>) async throws -> Void
    public var remove: (PersistedTeam) async throws -> Void
}

extension TeamPersistence {
    static let live =  {
        do {
            let persistence = try Persistence()
            return Self(
                publisher: { persistence.subject.eraseToAnyPublisher().values },
                load: { persistence.value },
                save: { try await persistence.save($0) },
                updateOrAppend: { try await persistence.updateOrAppend(team: $0) },
                updateValues: { try await persistence.update(values: $0) },
                remove: { try await persistence.remove(team: $0) }
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

public extension IdentifiedArrayOf<PersistedTeam> {
    static var example: Self {
        guard let koalaTeamId = UUID(uuidString: "00E9D827-9FAD-4686-83F2-FAD24D2531A2"),
              let purpleElephantId = UUID(uuidString: "98DBAF6C-685D-461F-9F81-E5E1E003B9AA"),
              let blueLionId = UUID(uuidString: "6634515C-19C9-47DF-8B2B-036736F9AEA9")
        else { fatalError("Cannot generate UUID from a defined UUID String") }

        let playersExample: IdentifiedArrayOf<PersistedPlayer> = .example
        let players = IdentifiedArrayOf<PersistedPlayer>(uniqueElements: playersExample.suffix(1))

        return [
            PersistedTeam(
                id: koalaTeamId,
                name: "Strawberry Koala",
                color: .strawberry,
                image: .koala,
                playerIDs: players.map(\.id),
                isArchived: false
            ),
            PersistedTeam(
                id: purpleElephantId,
                name: "Lilac Elephant",
                color: .lilac,
                image: .elephant,
                playerIDs: [],
                isArchived: false
            ),
            PersistedTeam(
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
