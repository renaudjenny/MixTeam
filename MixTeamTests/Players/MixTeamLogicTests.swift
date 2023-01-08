import ComposableArchitecture
import XCTest
@testable import MixTeam
import SwiftUI

class MixTeamLogicTests: XCTestCase {
    @MainActor
    func testMixTeam() async throws {
        let store = TestStore(initialState: .example, reducer: App())

        let allPlayers = store.state.data.composition.standing.players
        + store.state.data.composition.teams.flatMap(\.players)
        guard
            var amelia = allPlayers.first(where: { $0.name == "Amelia" }),
            var jack = allPlayers.first(where: { $0.name == "Jack" }),
            var jose = allPlayers.first(where: { $0.name == "José" })
        else { fatalError("Cannot instanciate named players") }

        jose.isStanding = false
        jose.color = store.state.data.teams[0].color
        jack.color = store.state.data.teams[1].color
        amelia.isStanding = false
        amelia.color = store.state.data.teams[2].color

        store.dependencies.shufflePlayers = .alphabeticallySorted
        store.dependencies.appPersistence.save = { _ in }
        store.dependencies.appPersistence.team.updateValues = { _ in }
        store.dependencies.appPersistence.saveComposition = { _ in }
        await store.send(.data(.composition(.mixTeam))) {
            $0.data.composition.notEnoughTeamsAlert = nil
            $0.data.composition.standing.players = []
            $0.data.composition.teams[id: $0.data.teams[0].id]?.players = [jose]
            $0.data.composition.teams[id: $0.data.teams[1].id]?.players = [jack]
            $0.data.composition.teams[id: $0.data.teams[2].id]?.players = [amelia]
        }

        await store.finish(timeout: 1)
    }

    func testMixTeamAndAlertIsPresented() throws {
        let store = TestStore(initialState: App.State(), reducer: App())

        store.send(.data(.composition(.mixTeam))) {
            $0.data.composition.notEnoughTeamsAlert = .notEnoughTeams
        }
    }
}
