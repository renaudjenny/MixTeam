//
//  UXUtils.swift
//  MixTeam
//
//  Created by Renaud JENNY on 08/05/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import UIKit

public struct UXColor {
    static let yellow = UIColor(red:0.95, green:0.98, blue:0.10, alpha:1.0)
    static let orange = UIColor(red:0.90, green:0.50, blue:0.10, alpha:1.0)
    static let red = UIColor(red:0.90, green:0.00, blue:0.24, alpha:1.0)
    static let maroon = UIColor(red:0.59, green:0.00, blue:0.21, alpha:1.0)
    static let purple	= UIColor(red:0.37, green:0.00, blue:0.55, alpha:1.0)
    static let azure = UIColor(red:0.27, green:0.50, blue:1.00, alpha:1.0)
    static let jade = UIColor(red:0.27, green:0.64, blue:0.59, alpha:1.0)
    static let lime = UIColor(red:0.38, green:0.89, blue:0.29, alpha:1.0)

    static func allColors() -> [UIColor] {
        return [self.yellow, self.orange, self.red, self.maroon, self.purple, self.azure, self.jade, self.lime]
    }

    static func toString(color: UIColor) -> String {
        switch color {
        case UXColor.yellow:
            return "yellow"
        case UXColor.orange:
            return "orange"
        case UXColor.red:
            return "red"
        case UXColor.maroon:
            return "maroon"
        case UXColor.purple:
            return "purple"
        case UXColor.azure:
            return "azure"
        case UXColor.jade:
            return "jade"
        case UXColor.lime:
            return "lime"
        default:
            return "unknown color"
        }
    }

    static func fromString(colorString: String) -> UIColor {
        switch colorString {
        case "yellow":
            return UXColor.yellow
        case "orange":
            return UXColor.orange
        case "red":
            return UXColor.red
        case "maroon":
            return UXColor.maroon
        case "purple":
            return UXColor.purple
        case "azure":
            return UXColor.azure
        case "jade":
            return UXColor.jade
        case "lime":
            return UXColor.lime
        default:
            return UIColor.gray
        }
    }
}

extension UIColor {
    var UXColorString: String {
        return UXColor.toString(color: self)
    }
}
