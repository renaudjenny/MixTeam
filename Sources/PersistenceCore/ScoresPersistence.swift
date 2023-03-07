import ComposableArchitecture
import Dependencies
import Foundation
import IdentifiedCollections
import XCTestDynamicOverlay

// TODO: change `(state: Scores)` to `(scores: Scores)`
private final class Persistence {
    private let scoresFileName = "MixTeamScoresV3_1_0"

    var value: Scores {
        didSet { Task { try await persist(value) } }
    }

    init() throws {
        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let data = try? Data(contentsOf: url.appendingPathComponent(scoresFileName, conformingTo: .json))
        else {
            value = .example
            return
        }

        let decodedValue = try JSONDecoder().decode(Scores.self, from: data)
        value = decodedValue
    }

    func save(_ state: Scores) async throws {
        value = state
    }

    private func persist(_ state: Scores) async throws {
        let data = try JSONEncoder().encode(state)
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw PersistenceError.cannotGetDocumentDirectoryWithUserDomainMask }
        try data.write(to: url.appendingPathComponent(scoresFileName, conformingTo: .json))
    }

    func update(round: Round) async throws {
        value.rounds.updateOrAppend(round)
    }

    func update(score: Score) async throws {
        guard var round = value.rounds.first(where: { $0.scores.contains(score) }) else { return }
        round.scores.updateOrAppend(score)
        try await update(round: round)
    }
}

public struct ScoresPersistence {
    public var load: () async throws -> Scores
    public var save: (Scores) async throws -> Void
    public var updateRound: (Round) async throws -> Void
    public var updateScore: (Score) async throws -> Void
}

extension ScoresPersistence {
    static let live = {
        do {
            let persistence = try Persistence()
            return Self(
                load: { persistence.value },
                save: { try await persistence.save($0) },
                updateRound: { try await persistence.update(round: $0) },
                updateScore: { try await persistence.update(score: $0) }
            )
        } catch {
            return Self(
                load: { throw error },
                save: { _ in throw error },
                updateRound: { _ in throw error },
                updateScore: { _ in throw error }
            )
        }
    }()
    static let test = Self(
        load: unimplemented("ScoresPersistence.load"),
        save: unimplemented("ScoresPersistence.save"),
        updateRound: unimplemented("ScoresPersistence.updateRound"),
        updateScore: unimplemented("ScoresPersistence.updateScpre")
    )
    static let preview = Self(
        load: { .example },
        save: { _ in print("ScoresPersistence.save called") },
        updateRound: { _ in print("ScoresPersistence.updateRound called") },
        updateScore: unimplemented("ScoresPersistence.updateScore called")
    )
}

extension Scores {
    static var example: Self {
        Self(rounds: [])
    }
}

private enum ScoresPersistenceDependencyKey: DependencyKey {
    static let liveValue = ScoresPersistence.live
    static let testValue = ScoresPersistence.test
    static let previewValue = ScoresPersistence.preview
}

public extension DependencyValues {
    var scoresPersistence: ScoresPersistence {
        get { self[ScoresPersistenceDependencyKey.self] }
        set { self[ScoresPersistenceDependencyKey.self] = newValue }
    }
}
