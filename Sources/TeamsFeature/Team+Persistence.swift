import ComposableArchitecture
import Foundation
import Models
import PlayersFeature

public extension Team.State {
    var persisted: PersistedTeam {
        PersistedTeam(
            id: id,
            name: name,
            color: color,
            image: image,
            playerIDs: players.map(\.id),
            isArchived: isArchived
        )
    }
}

public extension PersistedTeam {
    var state: Team.State {
        get async throws {
            @Dependency(\.playerPersistence) var playerPersistence

            let players = try await playerPersistence.load()
            let teamPlayers = IdentifiedArrayOf(uniqueElements: playerIDs.compactMap {
                var player = players[id: $0]?.state
                player?.color = color
                return player
            })
            return Team.State(
                id: id,
                name: name,
                color: color,
                image: image,
                players: teamPlayers,
                isArchived: isArchived
            )
        }
    }
}

public extension IdentifiedArrayOf<PersistedTeam> {
    var states: IdentifiedArrayOf<Team.State> {
        get async throws {
            var states: [Team.State] = []
            for team in self {
                states.append(try await team.state)
            }
            return IdentifiedArrayOf<Team.State>(uniqueElements: states)
        }
    }
}

public extension IdentifiedArrayOf<Team.State> {
    static var example: Self {
        let players = IdentifiedArrayOf<Player.State>.example
        var teams: Self = []

        for team in IdentifiedArrayOf<PersistedTeam>.example {
            var playerStates: IdentifiedArrayOf<Player.State> = []
            for playerID in team.playerIDs {
                if var playerState = players[id: playerID] {
                    playerState.color = team.color
                    playerStates.updateOrAppend(playerState)
                }
            }
            teams.updateOrAppend(Team.State(
                id: team.id,
                name: team.name,
                color: team.color,
                image: team.image,
                players: playerStates,
                isArchived: team.isArchived
            ))
        }
        return teams
    }
}
