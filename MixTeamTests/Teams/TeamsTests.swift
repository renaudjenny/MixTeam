import ComposableArchitecture
@testable import MixTeam
import XCTest

@MainActor
final class TeamsTests: XCTestCase {

    func testUpdateColor() async throws {
        let store = TestStore(initialState: Team.State.previewWithPlayers, reducer: Team())

        let updateExpectation = expectation(description: "Update team persistence")
        store.dependencies.teamPersistence.updateOrAppend = { _ in updateExpectation.fulfill() }

        await store.send(.binding(.set(\.$color, .strawberry))) {
            $0.color = .strawberry
            $0.players = IdentifiedArrayOf(uniqueElements: $0.players.map {
                var player = $0
                player.color = .strawberry
                return player
            })
        }
        wait(for: [updateExpectation], timeout: 0.1)
    }
}
