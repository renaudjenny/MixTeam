import ComposableArchitecture
import CompositionFeature
import SwiftUI
import TeamsFeature
import XCTest

@MainActor
class CompositionTests: XCTestCase {
    func testMixTeam() async throws {
        let store = TestStore(initialState: .example, reducer: Composition())

        let allPlayers = store.state.teams.flatMap(\.players) + store.state.standing.players
        guard
            var amelia = allPlayers.first(where: { $0.name == "Amelia" }),
            var jack = allPlayers.first(where: { $0.name == "Jack" }),
            var jose = allPlayers.first(where: { $0.name == "José" })
        else { fatalError("Cannot instanciate named players") }

        jose.color = store.state.teams[0].color
        jack.color = store.state.teams[1].color
        amelia.color = store.state.teams[2].color

        store.dependencies.shufflePlayers = .alphabeticallySorted
        store.dependencies.teamPersistence.save = { _ in }
        store.dependencies.teamPersistence.updateValues = { _ in }
        await store.send(.mixTeam) {
            $0.notEnoughTeamsConfirmationDialog = nil
            $0.standing.players = []
            $0.teams[id: $0.teams[0].id]?.players = [jose]
            $0.teams[id: $0.teams[1].id]?.players = [jack]
            $0.teams[id: $0.teams[2].id]?.players = [amelia]
        }

        await store.finish(timeout: 1)
    }

    func testMixTeamAndConfirmationIsPresented() async throws {
        let store = TestStore(initialState: Composition.State(), reducer: Composition())

        await store.send(.mixTeam) {
            $0.notEnoughTeamsConfirmationDialog = .notEnoughTeams
        }

        await store.send(.dismissNotEnoughTeamsAlert) {
            $0.notEnoughTeamsConfirmationDialog = nil
        }
    }

    func testAddTeam() async throws {
        let store = TestStore(initialState: Composition.State(), reducer: Composition())

        store.dependencies.uuid = .incrementing
        store.dependencies.randomTeam = .strawberryBunny
        let addTeamToPersistenceExpectation = expectation(description: "Persist team after adding it")
        store.dependencies.teamPersistence.updateOrAppend = { _ in addTeamToPersistenceExpectation.fulfill() }

        guard let id = UUID(uuidString: "00000000-0000-0000-0000-000000000000") else { return XCTFail("UUID missing") }

        await store.send(.addTeam) {
            $0.teams = [Team.State(id: id, name: "Strawberry Bunny", color: .strawberry, image: .bunny)]
        }
        wait(for: [addTeamToPersistenceExpectation], timeout: 0.1)
    }

    func testArchiveTeam() async throws {
        let store = TestStore(initialState: .example, reducer: Composition())

        let teams = store.state.teams
        let indexSet = IndexSet(integer: 0)

        let updateTeamsExpectation = expectation(description: "Update teams")
        store.dependencies.teamPersistence.updateValues = { archivedTeams in
            XCTAssertEqual(archivedTeams.elements.map(\.id), indexSet.map { teams[$0] }.map(\.id))
            XCTAssert(archivedTeams.allSatisfy(\.isArchived), "All archived teams should be in archived status")
            updateTeamsExpectation.fulfill()
        }

        await store.send(.archiveTeams(indexSet)) {
            $0.teams.remove(atOffsets: indexSet)
        }

        wait(for: [updateTeamsExpectation], timeout: 0.1)
    }
}
