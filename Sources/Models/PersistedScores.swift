import Foundation
import IdentifiedCollections

public struct PersistedScores: Codable {
    public var rounds: IdentifiedArrayOf<PersistedRound>

    public init(rounds: IdentifiedArrayOf<PersistedRound>) {
        self.rounds = rounds
    }
}

public struct PersistedRound: Codable, Identifiable {
    public let id: UUID
    public let name: String
    public var scores: IdentifiedArrayOf<PersistedScore>

    public init(id: UUID, name: String, scores: IdentifiedArrayOf<PersistedScore>) {
        self.id = id
        self.name = name
        self.scores = scores
    }
}

public struct PersistedScore: Codable, Identifiable {
    public let id: UUID
    public let teamID: PersistedTeam.ID
    public let points: Int

    public init(id: UUID, teamID: PersistedTeam.ID, points: Int) {
        self.id = id
        self.teamID = teamID
        self.points = points
    }
}
