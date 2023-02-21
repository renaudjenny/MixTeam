import ComposableArchitecture
@testable import MixTeam
import XCTest

@MainActor
final class StandingTests: XCTestCase {
    func testCreatePlayer() async {
        let updatePlayerExpectation = expectation(description: "Update player")
        let expectationUUIDGenerator: UUIDGenerator = .incrementing
        let newPlayer = Player.State(id: expectationUUIDGenerator(), name: "Test", image: .clown, color: .aluminium)
        let store = TestStore(initialState: Standing.State(), reducer: Standing()) { dependencies in
            dependencies.uuid = .incrementing
            dependencies.playerPersistence.updateOrAppend = { _ in updatePlayerExpectation.fulfill() }
            dependencies.randomPlayer = RandomPlayer { newPlayer }
        }

        await store.send(.createPlayer) {
            $0.players = [newPlayer]
        }
        wait(for: [updatePlayerExpectation], timeout: 0.1)
    }
}
