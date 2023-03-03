import ComposableArchitecture
@testable import MixTeam
import XCTest

@MainActor
final class TeamsTests: XCTestCase {

    func testUpdateColor() async throws {
        let store = TestStore(initialState: Team.State.previewWithPlayers, reducer: Team())

        let updateExpectation = expectation(description: "Update team persistence")
        store.dependencies.teamPersistence.updateOrAppend = { _ in updateExpectation.fulfill() }

        await store.send(.set(\.$color, .strawberry)) {
            $0.color = .strawberry
            $0.players = IdentifiedArrayOf(uniqueElements: $0.players.map {
                var player = $0
                player.color = .strawberry
                return player
            })
        }
        wait(for: [updateExpectation], timeout: 0.1)
    }

    func testUpdateName() async throws {
        let store = TestStore(initialState: Team.State.previewWithPlayers, reducer: Team())

        let updateExpectation = expectation(description: "Update team persistence")
        store.dependencies.teamPersistence.updateOrAppend = { _ in updateExpectation.fulfill() }

        await store.send(.set(\.$name, "Test")) {
            $0.name = "Test"
        }
        wait(for: [updateExpectation], timeout: 0.1)
    }

    func testUpdateImage() async throws {
        let store = TestStore(initialState: Team.State.previewWithPlayers, reducer: Team())

        let updateExpectation = expectation(description: "Update team persistence")
        store.dependencies.teamPersistence.updateOrAppend = { _ in updateExpectation.fulfill() }

        await store.send(.illustrationPicker(.imageTapped(.clown))) {
            $0.image = .clown
        }
        wait(for: [updateExpectation], timeout: 0.1)
    }

    func testMoveBackPlayer() async throws {
        let store = TestStore(initialState: Team.State.previewWithPlayers, reducer: Team())

        let updateExpectation = expectation(description: "Update team persistence")
        store.dependencies.teamPersistence.updateOrAppend = { _ in updateExpectation.fulfill() }

        let firstPlayerID = store.state.players.first?.id ?? UUID()

        await store.send(.moveBackPlayer(id: firstPlayerID)) {
            $0.players.remove(id: firstPlayerID)
        }
        wait(for: [updateExpectation], timeout: 0.1)
    }
}
