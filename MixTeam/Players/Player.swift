import ComposableArchitecture
import Foundation

struct Player: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: UUID
        @BindableState var name = ""
        @BindableState var image: MTImage = .unknown
        var color: MTColor = .aluminium
        var isStanding = false
        var isArchived = false
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case setEdit(isPresented: Bool)
        case delete
        case moveBack
    }

    @Dependency(\.appPersistence) var appPersistence

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .fireAndForget { [state] in try await appPersistence.player.updateOrAppend(state) }
            case .setEdit:
                return .none
            case .delete:
                return .fireAndForget { [state] in try await appPersistence.player.remove(state.id) }
            case .moveBack:
                return .fireAndForget { [state] in
                    let players = try await appPersistence.player.load()

                    var teams = try await appPersistence.team.load()
                    guard var team = teams.first(where: { $0.playerIDs.contains(state.id) }) else { return }
                    var teamPlayers = players.filter { team.playerIDs.contains($0.id) }
                    teamPlayers.remove(state)
                    team.players = .loaded(teamPlayers)
                    teams.updateOrAppend(team)

                    var standing = try await appPersistence.standing.load()
                    var standingPlayers = players.filter { standing.playerIDs.contains($0.id) }
                    standingPlayers.updateOrAppend(state)
                    standing.players = .loaded(standingPlayers)

                    try await appPersistence.team.save(teams)
                    try await appPersistence.standing.save(standing)
                }
            }
        }
    }
}

extension Player.State: Codable {
    enum CodingKeys: CodingKey {
        case id
        case name
        case image
    }
}
