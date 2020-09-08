import SwiftUI

enum ImageIdentifier: String, Identifiable, Codable {
    case elephant = "elephant"
    case koala = "koala"
    case panda = "panda"
    case octopus = "octopus"
    case lion = "lion"

    case harryPottar = "harry-pottar"
    case amaliePoulain = "amalie-poulain"
    case darkVadir = "dark-vadir"
    case laraCraft = "lara-craft"
    case theBotman = "the-botman"
    case wanderWoman = "wander-woman"
    case jack = "jack"

    case unknown = ""

    var image: Image {
        switch self {
        case .unknown: return Image(systemName: "questionmark")
        default: return Image(rawValue)
        }
    }

    var id: String { rawValue }

    static var players: [Self] {
        [
            .harryPottar, .amaliePoulain, .darkVadir,
            .laraCraft, .theBotman, .wanderWoman, .jack
        ]
    }

    static var teams: [Self] {
        [.elephant, .koala, .panda, .octopus, .lion]
    }

    var name: String {
        switch self {
        case .elephant: return "elephant"
        case .koala: return "koala"
        case .panda: return "panda"
        case .octopus: return "octopus"
        case .lion: return "lion"
        default: return ""
        }
    }
}
