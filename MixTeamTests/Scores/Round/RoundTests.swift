import ComposableArchitecture
@testable import MixTeam
import XCTest

@MainActor
final class RoundTests: XCTestCase {
    func testUpdateName() async {
        let updateRoundExpectation = expectation(description: "Update round")
        let uuid = UUIDGenerator.incrementing
        let state = Round.State(id: uuid(), name: "Test")
        let store = TestStore(initialState: state, reducer: Round()) { dependencies in
            dependencies.scoresPersistence.updateRound = { _ in updateRoundExpectation.fulfill() }
        }

        await store.send(.set(\.$name, "Test modified")) {
            $0.name = "Test modified"
        }
        wait(for: [updateRoundExpectation], timeout: 0.1)
    }

    func testRemoveScore() async throws {
        let uuid = UUIDGenerator.incrementing
        let scores: IdentifiedArrayOf<Score.State> = [
            Score.State(id: uuid(), team: .preview),
            Score.State(id: uuid(), team: .preview),
            Score.State(id: uuid(), team: .preview),
        ]
        let state = Round.State(id: uuid(), name: "Test", scores: scores)
        let store = TestStore(initialState: state, reducer: Round())

        let firstScore = try XCTUnwrap(scores.first)

        await store.send(.score(id: firstScore.id, action: .remove)) {
            $0.scores.remove(id: firstScore.id)
        }
    }
}
