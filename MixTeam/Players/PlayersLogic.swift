import SwiftUI
import Combine

protocol PlayersLogic {
    var teamsStore: TeamsStore { get }
    var teams: [Team] { get }

    func createPlayer(name: String, image: ImageIdentifier)
    func editPlayer(_ player: Player)
    func deletePlayer(_ player: Player)
    func moveBack(player: Player)
}

extension PlayersLogic {
    var teams: [Team] { teamsStore.teams }

    func createPlayer(name: String, image: ImageIdentifier) {
        guard var playersStandingForATeam = teams.first else { return }
        playersStandingForATeam.players.append(Player(name: name, imageIdentifier: image))
        teamsStore.teams[0] = playersStandingForATeam
    }

    func editPlayer(_ player: Player) {
        guard let teamIndex = teamsStore.teams.firstIndex(where: { $0.players.contains(player) }),
            let playerIndex = teamsStore.teams[teamIndex].players.firstIndex(of: player) else {
                return
        }
        teamsStore.teams[teamIndex].players[playerIndex] = player
    }

    func deletePlayer(_ player: Player) {
        guard let teamIndex = teamsStore.teams.firstIndex(where: { $0.players.contains(player) }),
            let playerIndex = teamsStore.teams[teamIndex].players.firstIndex(of: player) else {
                return
        }
        teamsStore.teams[teamIndex].players.remove(at: playerIndex)
    }

    func moveBack(player: Player) {
        guard teams.first != nil else { return }
        deletePlayer(player)
        teamsStore.teams[0].players.append(player)
    }
}
