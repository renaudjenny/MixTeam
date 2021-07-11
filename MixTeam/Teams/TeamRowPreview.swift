protocol TeamRowPreview {
    var debuggableCallbacks: TeamRow.Callbacks { get }
    var firstTeamDebuggableCallbacks: FirstTeamRow.Callbacks { get }
}

extension TeamRowPreview {
    var debuggableCallbacks: TeamRow.Callbacks {
        .init(
            editTeam: editTeam,
            deleteTeam: deleteTeam,
            editPlayer: editPlayer,
            moveBackPlayer: moveBackPlayer
        )
    }

    var firstTeamDebuggableCallbacks: FirstTeamRow.Callbacks {
        .init(
            createPlayer: createPlayer,
            editPlayer: editPlayer,
            deletePlayer: deletePlayer
        )
    }

    private func editTeam(team: Team) { print("edit team", team) }
    private func deleteTeam(team: Team) { print("delete team", team) }
    private func createPlayer() { print("create player") }
    private func editPlayer(player: Player) { print("edit player", player) }
    private func moveBackPlayer(player: Player) { print("move player", player) }
    private func deletePlayer(player: Player) { print("delete player", player) }
}
