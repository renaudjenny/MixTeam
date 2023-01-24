import ComposableArchitecture
import Dependencies
import Foundation
import IdentifiedCollections
import XCTestDynamicOverlay

private final class Persistence {
    private let scoresFileName = "MixTeamScoresV3_1_0"

    @Dependency(\.teamPersistence) var team

    var value: Scores.State {
        didSet { Task { try await persist(value) } }
    }

    init() throws {
        // TODO: migration from V2 & V3.0
        guard
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let data = try? Data(contentsOf: url.appendingPathComponent(scoresFileName, conformingTo: .json))
        else {
            value = .example
            return
        }

        let decodedValue = try JSONDecoder().decode(Scores.State.self, from: data)
        value = decodedValue
    }

    func save(_ state: Scores.State) async throws {
        value = state
    }

    private func persist(_ state: Scores.State) async throws {
        let data = try JSONEncoder().encode(state)
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { throw PersistenceError.cannotGetDocumentDirectoryWithUserDomainMask }
        try data.write(to: url.appendingPathComponent(scoresFileName, conformingTo: .json))
    }

    func inflated(value: Scores.State) async throws -> Scores.State {
        let teams = try await team.load()

        return Scores.State(
            teams: teams.filter { !$0.isArchived },
            rounds: IdentifiedArrayOf(uniqueElements: value.rounds.map {
                var round = $0
                round.scores = IdentifiedArrayOf(uniqueElements: round.scores.compactMap {
                    guard teams.contains($0.team) else { return nil }
                    var score = $0
                    score.team = teams[id: score.team.id] ?? score.team
                    return score
                })
                return round
            })
        )
    }

    func update(round: Round.State) async throws {
        value.rounds.updateOrAppend(round)
    }

    func update(score: Score.State) async throws {
        guard var round = value.rounds.first(where: { $0.scores.contains(score) }) else { return }
        round.scores.updateOrAppend(score)
        try await update(round: round)
    }
}

struct ScoresPersistence {
    var load: () async throws -> Scores.State
    var save: (Scores.State) async throws -> Void
    var updateRound: (Round.State) async throws -> Void
    var updateScore: (Score.State) async throws -> Void
}

extension ScoresPersistence {
    static let live = {
        do {
            let persistence = try Persistence()
            return Self(
                load: { try await persistence.inflated(value: persistence.value) },
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

extension Scores.State: Codable {
    enum CodingKeys: CodingKey {
        case rounds
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        rounds = try container.decode(IdentifiedArrayOf<Round.State>.self, forKey: .rounds)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rounds, forKey: .rounds)
    }
}

extension Score.State: Codable {
    enum CodingKeys: CodingKey {
        case id
        case teamID
        case points
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let teamID = try container.decode(Team.State.ID.self, forKey: .teamID)
        team = Team.State(id: teamID)
        id = try container.decode(Score.State.ID.self, forKey: .id)
        points = try container.decode(Int.self, forKey: .points)
        accumulatedPoints = 0
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(team.id, forKey: .teamID)
        try container.encode(points, forKey: .points)
    }
}

extension Scores.State {
    static var example: Self {
        Self(teams: .example)
    }
}

private enum ScoresPersistenceDependencyKey: DependencyKey {
    static let liveValue = ScoresPersistence.live
    static let testValue = ScoresPersistence.test
    static let previewValue = ScoresPersistence.preview
}

extension DependencyValues {
    var scoresPersistence: ScoresPersistence {
        get { self[ScoresPersistenceDependencyKey.self] }
        set { self[ScoresPersistenceDependencyKey.self] = newValue }
    }
}
