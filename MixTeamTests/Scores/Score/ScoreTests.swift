import ComposableArchitecture
@testable import MixTeam
import XCTest

@MainActor
final class ScoreTests: XCTestCase {
    func testSetPoints() async {
        let updateScoreExpectation = expectation(description: "Update score")
        let uuid: UUIDGenerator = .incrementing
        let state = Score.State(id: uuid(), team: .preview)
        let store = TestStore(initialState: state, reducer: Score()) { dependencies in
            dependencies.scoresPersistence.updateScore = { _ in updateScoreExpectation.fulfill() }
        }

        await store.send(.set(\.$points, 123)) {
            $0.points = 123
        }
        wait(for: [updateScoreExpectation], timeout: 0.1)
    }
}
