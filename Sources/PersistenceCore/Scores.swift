import Foundation
import IdentifiedCollections

public struct Scores: Codable {
    public internal(set) var rounds: IdentifiedArrayOf<Round>
}

public struct Round: Codable, Identifiable {
    public let id: UUID
    public let name: String
    public internal(set) var scores: IdentifiedArrayOf<Score>

    public init(id: UUID, name: String, scores: IdentifiedArrayOf<Score>) {
        self.id = id
        self.name = name
        self.scores = scores
    }
}

public struct Score: Codable, Identifiable {
    public let id: UUID
    public let teamID: Team.ID
    public let points: Int
}
