import SwiftUI

enum MTImage: String, Identifiable, Codable {
    case elephant = "elephant"
    case koala = "koala"
    case panda = "panda"
    case octopus = "octopus"
    case lion = "lion"
    case hippo = "hippo"

    case girl = "girl"
    case woman = "woman"
    case jack = "jack"
    case santa = "santa"
    case clown = "clown"
    case pirate = "pirate"
    case lolita = "lolita"

    case unknown = ""

    var id: Int { hashValue }
}

extension MTImage {
    static var players: [Self] {
        [.girl, .santa, .jack, .woman, .clown, .pirate, .lolita]
    }
    static var teams: [Self] {
        [.elephant, .koala, .panda, .octopus, .lion, .hippo]
    }
}

extension Image {
    init(mtImage: MTImage) {
        switch mtImage {
        case .unknown: self = Image(systemName: "questionmark")
        default: self = Image(mtImage.rawValue)
        }
    }
}
