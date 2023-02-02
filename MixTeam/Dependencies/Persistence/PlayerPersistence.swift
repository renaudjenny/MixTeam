import Combine
import Foundation
import Dependencies
import IdentifiedCollections
import XCTestDynamicOverlay

private final class Persistence {
    private let playerFileName = "MixTeamPlayerV3_0_0"

    let subject = PassthroughSubject<IdentifiedArrayOf<Player.State>, Error>()
    var value: IdentifiedArrayOf<Player.State> {
        didSet { Task { try await persist(value) } }
    }

    init() throws {
        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let data = try? Data(contentsOf: url.appendingPathComponent(playerFileName, conformingTo: .json))
        else {
            value = .example
            subject.send(value)
            return
        }

        let decodedValue = try JSONDecoder().decode(IdentifiedArrayOf<Player.State>.self, from: data)
        value = decodedValue
        subject.send(value)
    }

    func save(_ states: IdentifiedArrayOf<Player.State>) async throws {
        value = states
        subject.send(value)
    }

    func persist(_ states: IdentifiedArrayOf<Player.State>) async throws {
        let data = try JSONEncoder().encode(states)
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw PersistenceError.cannotGetDocumentDirectoryWithUserDomainMask }
        try data.write(to: url.appendingPathComponent(playerFileName, conformingTo: .json))
    }

    func updateOrAppend(state: Player.State) async throws {
        value.updateOrAppend(state)
        subject.send(value)
    }
    func remove(id: Player.State.ID) async throws {
        value.remove(id: id)
        subject.send(value)
    }
}

struct PlayerPersistence {
    var publisher: () -> AsyncThrowingPublisher<AnyPublisher<IdentifiedArrayOf<Player.State>, Error>>
    var load: () async throws -> IdentifiedArrayOf<Player.State>
    var save: (IdentifiedArrayOf<Player.State>) async throws -> Void
    var updateOrAppend: (Player.State) async throws -> Void
    var remove: (Player.State.ID) async throws -> Void
}

extension PlayerPersistence {
    static let live = {
        do {
            let persistence = try Persistence()
            return Self(
                publisher: { persistence.subject.eraseToAnyPublisher().values },
                load: { persistence.value },
                save: { try await persistence.save($0) },
                updateOrAppend: { try await persistence.updateOrAppend(state: $0) },
                remove: { try await persistence.remove(id: $0) }
            )
        } catch {
            return Self(
                publisher: { .with(error: error) },
                load: { throw error },
                save: { _ in throw error },
                updateOrAppend: { _ in throw error },
                remove: { _ in throw error }
            )
        }
    }()
    static let test = Self(
        publisher: unimplemented("PlayerPersistence.publisher"),
        load: unimplemented("PlayerPersistence.load"),
        save: unimplemented("PlayerPersistence.save"),
        updateOrAppend: unimplemented("PlayerPersistence.updateOrAppend"),
        remove: unimplemented("PlayerPersistence.remove")
    )
    static let preview = Self(
        publisher: { Result.Publisher(.example).eraseToAnyPublisher().values },
        load: { .example },
        save: { _ in print("PlayerPersistence.save called") },
        updateOrAppend: { _ in print("PlayerPersistence.updateOrAppend called") },
        remove: { _ in print("PlayerPersistence.remove called") }
    )
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

private enum PlayerPersistenceDependencyKey: DependencyKey {
    static let liveValue = PlayerPersistence.live
    static let testValue = PlayerPersistence.test
    static let previewValue = PlayerPersistence.test
}

extension DependencyValues {
    var playerPersistence: PlayerPersistence {
        get { self[PlayerPersistenceDependencyKey.self] }
        set { self[PlayerPersistenceDependencyKey.self] = newValue }
    }
}

#if DEBUG
extension AsyncThrowingPublisher where P == AnyPublisher<IdentifiedArrayOf<Player.State>, Error> {

    static func with(value: Element) -> Self {
        Result.Publisher(value).eraseToAnyPublisher().values
    }

    static func with(error: Error) -> Self {
        Fail(error: error).eraseToAnyPublisher().values
    }
}
#endif
