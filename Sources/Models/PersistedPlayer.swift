import Assets
import Foundation

public struct PersistedPlayer: Codable, Identifiable, Equatable {
    public let id: UUID
    public let name: String
    public let image: MTImage

    public init(id: UUID, name: String, image: MTImage) {
        self.id = id
        self.name = name
        self.image = image
    }
}
