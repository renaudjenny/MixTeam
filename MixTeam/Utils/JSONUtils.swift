import UIKit
import SwiftUI

/// Deprecated. Use ImageIdentifier instead
enum AppImage: String, Codable, Identifiable {
    case unknown = "unknown image"
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

    var image: UIImage {
        guard let image = UIImage(named: self.rawValue) else {
            return #imageLiteral(resourceName: "unknown")
        }
        return image
    }

    var id: String {
        self.rawValue
    }
}

extension UIImage {
    var appImage: AppImage {
        switch self {
        case #imageLiteral(resourceName: "elephant"):
            return .elephant
        case #imageLiteral(resourceName: "koala"):
            return .koala
        case #imageLiteral(resourceName: "panda"):
            return .panda
        case #imageLiteral(resourceName: "octopus"):
            return .octopus
        case #imageLiteral(resourceName: "lion"):
            return .lion
        case #imageLiteral(resourceName: "harry-pottar"):
            return .harryPottar
        case #imageLiteral(resourceName: "amalie-poulain"):
            return .amaliePoulain
        case #imageLiteral(resourceName: "dark-vadir"):
            return .darkVadir
        case #imageLiteral(resourceName: "lara-craft"):
            return .laraCraft
        case #imageLiteral(resourceName: "the-botman"):
            return .theBotman
        case #imageLiteral(resourceName: "wander-woman"):
            return .wanderWoman
        default:
            return .unknown
        }
    }

    func tint(with color: UIColor) -> UIImage {
        var image = self.withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.set()

        image.draw(in: CGRect(origin: .zero, size: size))
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

enum ImageIdentifier: String, Identifiable {
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

    var image: Image { Image(rawValue) }

    var id: String { rawValue }

    static var players: [Self] {
        [.harryPottar, .amaliePoulain, .darkVadir,
         .laraCraft, .theBotman, .wanderWoman]
    }

    // TODO: temporary, remove that ASAP
    var appImage: AppImage {
        AppImage(rawValue: self.rawValue) ?? .unknown
    }
}
