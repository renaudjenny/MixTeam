import ComposableArchitecture
import XCTest
@testable import MixTeam

@MainActor
class AppTests: XCTestCase {
    func testSelectTab() async throws {
        let store = TestStore(initialState: .example, reducer: App())

        await store.send(.tabSelected(.scoreboard)) {
            $0.selectedTab = .scoreboard
        }

        await store.send(.tabSelected(.settings)) {
            $0.selectedTab = .settings
        }

        await store.send(.tabSelected(.compositionLoader)) {
            $0.selectedTab = .compositionLoader
        }
    }

    func testTask() async throws {
        let store = TestStore(initialState: .example, reducer: App())

        let migrationV2toV3Expectation = self.expectation(description: "Migration V2 to V3 being called")
        store.dependencies.migration.v2toV3 = { migrationV2toV3Expectation.fulfill() }

        let migrationV3_0toV3_1Expectation = self.expectation(description: "Migration V3.0 to V3.1 being called")
        store.dependencies.migration.v3_0toV3_1 = { migrationV3_0toV3_1Expectation.fulfill() }

        await store.send(.task)
        wait(for: [migrationV2toV3Expectation, migrationV3_0toV3_1Expectation], timeout: 0.1)
    }
}
