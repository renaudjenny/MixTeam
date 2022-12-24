import ComposableArchitecture
import Foundation

extension Scores.State: Codable {
    enum CodingKeys: CodingKey {
        case rounds
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        rounds = try container.decode(IdentifiedArrayOf<Round.State>.self, forKey: .rounds)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rounds, forKey: .rounds)
    }
}

extension Round.State: Codable {
    enum CodingKeys: CodingKey {
        case id
        case name
        case scores
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Round.State.ID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        scores = try container.decode(IdentifiedArrayOf<Score.State>.self, forKey: .scores)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(scores, forKey: .scores)
    }
}

extension Score.State: Codable {
    enum CodingKeys: CodingKey {
        case id
        case teamID
        case points
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let teamID = try container.decode(Team.State.ID.self, forKey: .teamID)
        team = Team.State(id: teamID)
        id = try container.decode(Score.State.ID.self, forKey: .id)
        points = try container.decode(Int.self, forKey: .points)
        accumulatedPoints = 0
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(team.id, forKey: .teamID)
        try container.encode(points, forKey: .points)
    }
}
