import Assets
import Foundation

public struct Team: Codable, Identifiable {
    public let id: UUID
    public let name: String
    public let color: MTColor
    public let image: MTImage
    public let playerIDs: [Player.ID]
    public internal(set) var isArchived: Bool

    public init(id: UUID, name: String, color: MTColor, image: MTImage, playerIDs: [Player.ID], isArchived: Bool) {
        self.id = id
        self.name = name
        self.color = color
        self.image = image
        self.playerIDs = playerIDs
        self.isArchived = isArchived
    }
}
