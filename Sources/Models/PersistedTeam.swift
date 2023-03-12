import Assets
import Foundation

public struct PersistedTeam: Codable, Identifiable {
    public var id: UUID
    public var name: String
    public var color: MTColor
    public var image: MTImage
    public var playerIDs: [PersistedPlayer.ID]
    public var isArchived: Bool

    public init(
        id: UUID,
        name: String,
        color: MTColor,
        image: MTImage,
        playerIDs: [PersistedPlayer.ID],
        isArchived: Bool
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.image = image
        self.playerIDs = playerIDs
        self.isArchived = isArchived
    }
}
