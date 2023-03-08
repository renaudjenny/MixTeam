import ComposableArchitecture
import ScoresFeature
import XCTest

@MainActor
final class ScoresTest: XCTestCase {
    func testAddRound() async throws {
        let saveScoresExpectation = expectation(description: "Save Scores")
        let store = TestStore(initialState: .previewWithScores(count: 3), reducer: Scores()) {
            $0.uuid = .incrementing
            $0.scoresPersistence.save = { _ in saveScoresExpectation.fulfill() }
        }
        let uuid = UUIDGenerator.incrementing

        let scores = IdentifiedArrayOf(uniqueElements: store.state.teams.filter { !$0.isArchived }.map { team in
            Score.State(
                id: uuid(),
                team: team,
                points: 0,
                accumulatedPoints: store.state.rounds
                    .flatMap(\.scores)
                    .filter { $0.team == team }
                    .map(\.points)
                    .reduce(0, +)
            )
        })

        let newRound = Round.State(id: uuid(), name: "Round 4", scores: scores)
        await store.send(.addRound) {
            $0.rounds.append(newRound)
        }
        wait(for: [saveScoresExpectation], timeout: 0.1)
    }

    func testUpdateAccumulatedPoints() async throws {
        let store = TestStore(initialState: .previewWithScores(count: 3), reducer: Scores())
        let rounds = IdentifiedArrayOf(uniqueElements: store.state.rounds.map { round in
            var round = round
            round.scores = IdentifiedArrayOf(uniqueElements: round.scores.map { score in
                var score = score
                score.accumulatedPoints += 10
                return score
            })
            return round
        })

        await store.send(.updateAccumulatedPoints(rounds)) {
            $0.rounds = rounds
        }
    }
}
