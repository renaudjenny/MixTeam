import ComposableArchitecture
@testable import MixTeam
import XCTest

@MainActor
final class SettingsTests: XCTestCase {

    // There is no logic yet in Settings, it's just an intermediate step to Archive or About View
    func testNothing() async throws {
        let store = TestStore(initialState: Settings.State(), reducer: Settings())

        _ = store
    }
}
