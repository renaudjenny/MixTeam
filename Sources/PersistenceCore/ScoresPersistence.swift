import ComposableArchitecture
import Dependencies
import Foundation
import IdentifiedCollections
import Models
import XCTestDynamicOverlay

private final class Persistence {
    private let scoresFileName = "MixTeamScoresV3_1_0"

    var value: PersistedScores {
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

        let decodedValue = try JSONDecoder().decode(PersistedScores.self, from: data)
        value = decodedValue
    }

    func save(_ scores: PersistedScores) async throws {
        value = scores
    }

    private func persist(_ scores: PersistedScores) async throws {
        let data = try JSONEncoder().encode(scores)
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw PersistenceError.cannotGetDocumentDirectoryWithUserDomainMask }
        try data.write(to: url.appendingPathComponent(scoresFileName, conformingTo: .json))
    }

    func update(round: PersistedRound) async throws {
        value.rounds.updateOrAppend(round)
    }

    func update(score: PersistedScore) async throws {
        guard var round = value.rounds.first(where: { $0.scores.contains(score) }) else { return }
        round.scores.updateOrAppend(score)
        try await update(round: round)
    }
}

public struct LegacyScoresPersistence {
    public var load: () async throws -> PersistedScores
    public var save: (PersistedScores) async throws -> Void
    public var updateRound: (PersistedRound) async throws -> Void
    public var updateScore: (PersistedScore) async throws -> Void
}

extension LegacyScoresPersistence {
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

extension PersistedScores {
    static var example: Self {
        Self(rounds: [])
    }
}

private enum ScoresPersistenceDependencyKey: DependencyKey {
    static let liveValue = LegacyScoresPersistence.live
    static let testValue = LegacyScoresPersistence.test
    static let previewValue = LegacyScoresPersistence.preview
}

public extension DependencyValues {
    var legacyScoresPersistence: LegacyScoresPersistence {
        get { self[ScoresPersistenceDependencyKey.self] }
        set { self[ScoresPersistenceDependencyKey.self] = newValue }
    }
}
