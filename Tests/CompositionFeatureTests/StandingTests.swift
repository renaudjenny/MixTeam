import ComposableArchitecture
import CompositionFeature
import PlayersFeature
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

    func testDeletePlayer() async throws {
        let removePlayerExpectation = expectation(description: "Remove Player")
        let store = TestStore(initialState: .example, reducer: Standing()) { dependencies in
            dependencies.playerPersistence.remove = { _ in removePlayerExpectation.fulfill() }
        }
        let playerToRemove = try XCTUnwrap(store.state.players.first)

        await store.send(.deletePlayer(id: playerToRemove.id)) {
            $0.players.remove(id: playerToRemove.id)
        }
        wait(for: [removePlayerExpectation], timeout: 0.1)
    }
}
