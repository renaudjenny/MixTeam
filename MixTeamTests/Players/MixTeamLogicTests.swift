import ComposableArchitecture
import XCTest
@testable import MixTeam
import SwiftUI

class MixTeamLogicTests: XCTestCase {
    @MainActor
    func testMixTeam() async throws {
        let store = TestStore(initialState: .example, reducer: App())

        let allPlayers = store.state.composition.standing.players + store.state.composition.teams.flatMap(\.players)
        guard
            var amelia = allPlayers.first(where: { $0.name == "Amelia" }),
            var jack = allPlayers.first(where: { $0.name == "Jack" }),
            var jose = allPlayers.first(where: { $0.name == "José" })
        else { fatalError("Cannot instanciate named players") }

        jose.isStanding = false
        jose.color = store.state.teams[0].color
        jack.color = store.state.teams[1].color
        amelia.isStanding = false
        amelia.color = store.state.teams[2].color

        store.dependencies.shufflePlayers = .alphabeticallySorted
        store.dependencies.appPersistence.save = { _ in }
        store.dependencies.appPersistence.team.updateValues = { _ in }
        store.dependencies.appPersistence.saveComposition = { _ in }
        await store.send(.composition(.mixTeam)) {
            $0.composition.notEnoughTeamsAlert = nil
            $0.composition.standing.players = []
            $0.composition.teams[id: $0.teams[0].id]?.players = [jose]
            $0.composition.teams[id: $0.teams[1].id]?.players = [jack]
            $0.composition.teams[id: $0.teams[2].id]?.players = [amelia]
        }

        await store.finish(timeout: 1)
    }

    func testMixTeamAndAlertIsPresented() throws {
        let store = TestStore(initialState: App.State(), reducer: App())

        store.send(.composition(.mixTeam)) {
            $0.composition.notEnoughTeamsAlert = .notEnoughTeams
        }
    }
}
