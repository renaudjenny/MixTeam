import Assets
import Foundation

public struct Team: Codable, Identifiable {
    public var id: UUID
    public var name: String
    public var color: MTColor
    public var image: MTImage
    public var playerIDs: [Player.ID]
    public var isArchived: Bool

    public init(id: UUID, name: String, color: MTColor, image: MTImage, playerIDs: [Player.ID], isArchived: Bool) {
        self.id = id
        self.name = name
        self.color = color
        self.image = image
        self.playerIDs = playerIDs
        self.isArchived = isArchived
    }
}
