import ComposableArchitecture
import XCTest
@testable import MixTeam
import SwiftUI

class CompositionTests: XCTestCase {
    @MainActor
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

    func testMixTeamAndConfirmationIsPresented() throws {
        let store = TestStore(initialState: Composition.State(), reducer: Composition())

        store.send(.mixTeam) {
            $0.notEnoughTeamsConfirmationDialog = .notEnoughTeams
        }
    }
}
