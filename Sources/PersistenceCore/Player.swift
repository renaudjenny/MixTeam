import Assets
import Foundation

public struct Player: Codable, Identifiable {
    public let id: UUID
    public let name: String
    public let image: MTImage

    public init(id: UUID, name: String, image: MTImage) {
        self.id = id
        self.name = name
        self.image = image
    }
}
