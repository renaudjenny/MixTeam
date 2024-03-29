import ComposableArchitecture
import PlayersFeature
import XCTest

@MainActor
final class PlayersTests: XCTestCase {
    func testUpdateName() async throws {
        let store = TestStore(initialState: Player.State.preview, reducer: Player())

        let updateExpectation = expectation(description: "Update player persistence")
        store.dependencies.playerPersistence.updateOrAppend = { _ in updateExpectation.fulfill() }

        await store.send(.set(\.$name, "Test")) {
            $0.name = "Test"
        }
        wait(for: [updateExpectation], timeout: 0.1)
    }

    func testUpdateImage() async throws {
        let store = TestStore(initialState: Player.State.preview, reducer: Player())

        let updateExpectation = expectation(description: "Update player persistence")
        store.dependencies.playerPersistence.updateOrAppend = { _ in updateExpectation.fulfill() }

        await store.send(.illustrationPicker(.imageTapped(.nymph))) {
            $0.image = .nymph
        }
        wait(for: [updateExpectation], timeout: 0.1)
    }
}
