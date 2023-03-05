import ComposableArchitecture
import ArchivesCore
import XCTest

@MainActor
final class ArchiveRowTests: XCTestCase {
    func testUnarchive() async throws {
        let store = TestStore(initialState: ArchiveRow.State(team: .previewArchived), reducer: ArchiveRow())

        let updateTeamExpectation = expectation(description: "Update team is called")
        store.dependencies.teamPersistence.updateOrAppend = { _ in updateTeamExpectation.fulfill() }

        await store.send(.unarchive) {
            $0.team.isArchived = false
        }
        wait(for: [updateTeamExpectation], timeout: 0.1)
    }
}
