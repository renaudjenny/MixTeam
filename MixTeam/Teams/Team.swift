import IdentifiedCollections
import Foundation

struct Team: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String = ""
    var colorIdentifier: ColorIdentifier = .gray
    var imageIdentifier: ImageIdentifier = .unknown
    var players: IdentifiedArrayOf<Player> = []
}

#if DEBUG
extension Team {
    static var test: Self {
        Team(
            id: UUID(),
            name: "Team Test",
            colorIdentifier: .red,
            imageIdentifier: .koala,
            players: []
        )
    }
}
#endif
