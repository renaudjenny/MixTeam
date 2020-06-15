import SwiftUI

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
