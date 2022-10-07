import Foundation

struct Player: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String = ""
    var imageIdentifier: ImageIdentifier
}

#if DEBUG
extension Player {
    static var test: Self {
        Player(id: UUID(), name: "Test", imageIdentifier: .girl)
    }
}
#endif
