import Models

extension Score.State {
    var persisted: PersistedScore {
        PersistedScore(id: id, teamID: team.id, points: points)
    }
}
