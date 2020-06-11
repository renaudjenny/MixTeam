//
//  UXUtils.swift
//  MixTeam
//
//  Created by Renaud JENNY on 08/05/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import UIKit

// TODO: remove UX color and use ColorIdentifier instead
enum UXColor: String, Codable, Identifiable {
    case yellow
    case orange
    case red
    case maroon
    case purple
    case azure
    case jade
    case lime
    case gray

    var color: UIColor {
        switch self {
        case .yellow:
            return UIColor(red:0.95, green:0.98, blue:0.10, alpha:1.0)
        case .orange:
            return UIColor(red:0.90, green:0.50, blue:0.10, alpha:1.0)
        case .red:
            return UIColor(red:0.90, green:0.00, blue:0.24, alpha:1.0)
        case .maroon:
            return UIColor(red:0.59, green:0.00, blue:0.21, alpha:1.0)
        case .purple:
            return UIColor(red:0.37, green:0.00, blue:0.55, alpha:1.0)
        case .azure:
            return UIColor(red:0.27, green:0.50, blue:1.00, alpha:1.0)
        case .jade:
            return UIColor(red:0.27, green:0.64, blue:0.59, alpha:1.0)
        case .lime:
            return UIColor(red:0.38, green:0.89, blue:0.29, alpha:1.0)
        case .gray:
            return UIColor(red:0.5, green:0.5, blue:0.5, alpha:1.0)
        }
    }

    static let allColors: [UXColor] = [
        .yellow, .orange, .red,
        .maroon, .purple, .azure,
        .jade, .lime
    ]

    var id: Int { hashValue }
}

extension UIColor {
    var uxColor: UXColor {
        guard let uxColor = UXColor.allColors.first(where: { $0.color == self }) else {
            return UXColor.gray
        }
        return uxColor
    }
}
