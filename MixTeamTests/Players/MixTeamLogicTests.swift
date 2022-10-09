import ComposableArchitecture
import XCTest
@testable import MixTeam
import SwiftUI

class MixTeamLogicTests: XCTestCase {
    func testMixTeamWhenThereIsMoreThan2TeamsAvailableAndMixTeamThenNoAlertIsPresentedAndPlayersAreMixed() throws {
        let store = TestStore(initialState: .example, reducer: App())

        let allPlayers = store.state.standing.players + store.state.teams.flatMap(\.players)
        let amelia = allPlayers.first { $0.name == "Amelia" }!
        let jack = allPlayers.first { $0.name == "Jack" }!
        let jose = allPlayers.first { $0.name == "José" }!

        store.dependencies.shufflePlayers = .alphabeticallySorted
        store.dependencies.save = { _ in }
        store.send(.mixTeam) {
            $0.notEnoughTeamsAlert = nil
            $0.standing.players = []
            $0.teams[id: $0.teams[0].id]?.players = [jose]
            $0.teams[id: $0.teams[1].id]?.players = [jack]
            $0.teams[id: $0.teams[2].id]?.players = [amelia]
        }
        store.receive(.saveTeams)
    }

    func testMixTeamWhenThereIsLessThan2TeamsAvailableAndMixTeamThenAlertIsPresented() throws {
        let store = TestStore(initialState: App.State(), reducer: App())

        store.send(.mixTeam) {
            $0.notEnoughTeamsAlert = .notEnoughTeams
        }
    }
}
