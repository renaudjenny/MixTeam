import SwiftUI
import Combine

protocol PlayersLogic {
    var teamsStore: TeamsStore { get }
    var teams: [Team] { get }

    func createRandomPlayer()
    func edit(player: Player)
    func delete(player: Player)
    func moveBack(player: Player)
}

extension PlayersLogic {
    var teams: [Team] { teamsStore.teams }

    func createRandomPlayer() {
        guard teams.first != nil else { return }
        let name = Player.placeholders.randomElement() ?? ""
        let image = ImageIdentifier.players.randomElement() ?? .unknown
        let player = Player(name: name, imageIdentifier: image)
        teamsStore.teams[0].players.append(player)
    }

    func edit(player: Player) {
        guard let teamIndex = teamsStore.teams.firstIndex(where: { $0.players.contains(player) }),
            let playerIndex = teamsStore.teams[teamIndex].players.firstIndex(of: player) else {
                return
        }
        teamsStore.teams[teamIndex].players[playerIndex] = player
    }

    func delete(player: Player) {
        guard let teamIndex = teamsStore.teams.firstIndex(where: { $0.players.contains(player) }),
            let playerIndex = teamsStore.teams[teamIndex].players.firstIndex(of: player) else {
                return
        }
        teamsStore.teams[teamIndex].players.remove(at: playerIndex)
    }

    func moveBack(player: Player) {
        guard teams.first != nil else { return }
        delete(player: player)
        teamsStore.teams[0].players.append(player)
    }
}

extension Player {
    static let placeholders = ["Mathilde", "Renaud", "John", "Alice", "Bob", "CJ"]

}
