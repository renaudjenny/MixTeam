import ComposableArchitecture
import XCTest
@testable import MixTeam
import SwiftUI

class MixTeamLogicTests: XCTestCase {
    func testMixTeamWhenThereIsMoreThan2TeamsAvailableAndMixTeamThenNoAlertIsPresentedAndPlayersAreMixed() throws {
        let store = TestStore(initialState: .example, reducer: App())

        let allPlayers = store.state.standing.players + store.state.teams.flatMap(\.players)
        var amelia = allPlayers.first { $0.name == "Amelia" }!
        var jack = allPlayers.first { $0.name == "Jack" }!
        var jose = allPlayers.first { $0.name == "José" }!

        jose.isStanding = false
        jose.color = store.state.teams[0].color
        jack.color = store.state.teams[1].color
        amelia.isStanding = false
        amelia.color = store.state.teams[2].color

        store.dependencies.shufflePlayers = .alphabeticallySorted
        store.dependencies.save = { _ in }
        store.send(.mixTeam) {
            $0.notEnoughTeamsAlert = nil
            $0.standing.players = []
            $0.teams[id: $0.teams[0].id]?.players = [jose]
            $0.teams[id: $0.teams[1].id]?.players = [jack]
            $0.teams[id: $0.teams[2].id]?.players = [amelia]
        }
        store.receive(.saveState)
    }

    func testMixTeamWhenThereIsLessThan2TeamsAvailableAndMixTeamThenAlertIsPresented() throws {
        let store = TestStore(initialState: App.State(), reducer: App())

        store.send(.mixTeam) {
            $0.notEnoughTeamsAlert = .notEnoughTeams
        }
    }
}
