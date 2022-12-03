import ComposableArchitecture
import Foundation

struct Score: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: UUID
        var team: Team.State
        @BindableState var points: Int

        var accumulatedPoints = 0
    }

    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case remove
    }

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
    }
}

extension Score.State: Codable {
    enum CodingKeys: CodingKey {
        case id
        case teamID
        case points
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        let teamID = try values.decode(Team.State.ID.self, forKey: .teamID)
        team = Team.State(id: teamID)
        points = try values.decode(Int.self, forKey: .points)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(team.id, forKey: .teamID)
        try container.encode(points, forKey: .points)
    }
}
