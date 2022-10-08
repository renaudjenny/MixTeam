import SwiftUI
import Combine

protocol TeamsLogic {
    var teamsStore: TeamsStore { get }

    func createRandomTeam()
    func edit(team: DprTeam)
    func delete(team: DprTeam)
}

extension TeamsLogic {
    func createRandomTeam() {
        let image = ImageIdentifier.teams.randomElement() ?? .koala
        let color = ColorIdentifier.allCases.randomElement() ?? .red
        let name = "\(color.name) \(image.name)".localizedCapitalized

        withAnimation {
            teamsStore.teams.append(DprTeam(
                name: name,
                colorIdentifier: color,
                imageIdentifier: image
            ))
        }
    }

    func delete(team: DprTeam) {
        guard let index = teamsStore.teams.firstIndex(of: team) else { return }
        guard index > 0 else { return }

        let playersInDeletedTeam = teamsStore.teams[index].players
        teamsStore.teams[0].players.append(contentsOf: playersInDeletedTeam)

        guard teamsStore.teams.firstIndex(of: team) != nil else { return }
        withAnimation {
            _ = teamsStore.teams.remove(at: index)
        }
    }

    func edit(team: DprTeam) {
        guard let teamIndex = teamsStore.teams.firstIndex(of: team) else {
            return
        }
        teamsStore.teams[teamIndex] = team
    }
}
