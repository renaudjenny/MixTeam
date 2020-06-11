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

enum ColorIdentifier: String, Identifiable, CaseIterable, Codable {
    case yellow
    case orange
    case red
    case maroon
    case purple
    case azure
    case jade
    case lime
    case gray

    var color: Color {
        switch self {
        case .yellow: return Color(red:0.95, green:0.98, blue:0.10)
        case .orange: return Color(red:0.90, green:0.50, blue:0.10)
        case .red: return Color(red:0.90, green:0.00, blue:0.24)
        case .maroon: return Color(red:0.59, green:0.00, blue:0.21)
        case .purple: return Color(red:0.37, green:0.00, blue:0.55)
        case .azure: return Color(red:0.27, green:0.50, blue:1.00)
        case .jade: return Color(red:0.27, green:0.64, blue:0.59)
        case .lime: return Color(red:0.38, green:0.89, blue:0.29)
        case .gray: return Color(red:0.5, green:0.5, blue:0.5)
        }
    }

    var name: String {
        switch self {
        case .yellow: return "yellow"
        case .orange: return "orange"
        case .red: return "red"
        case .maroon: return "maroon"
        case .purple: return "purple"
        case .azure: return "azure"
        case .jade: return "jade"
        case .lime: return "lime"
        case .gray: return "gray"
        }
    }

    var id: Int { hashValue }
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

    // TODO: temporary, remove that ASAP
    var appImage: AppImage {
        AppImage(rawValue: self.rawValue) ?? .unknown
    }
}

// TODO: temporary, remove that ASAP
extension AppImage {
    var imageIdentifier: ImageIdentifier {
        get { ImageIdentifier(rawValue: self.rawValue) ?? .theBotman }
        set { self = newValue.appImage }
    }
}
