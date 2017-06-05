//
//  Team.swift
//  MixTeam
//
//  Created by Renaud JENNY on 17/05/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import UIKit

class Team {
    let id = UUID()
    var name: String = ""
    var color: UIColor = UIColor.gray
    var image: UIImage? = nil
    var players: [Player] = []

    // FIXME: replace by a database system
    static var teams: [Team] = [
        Team(name: "Purple Elephants", color: UXColor.purple, image: #imageLiteral(resourceName: "elephant")),
        Team(name: "Blue Elephants", color: UXColor.azure, image: #imageLiteral(resourceName: "elephant")),
        Team(name: "Red Elephants", color: UXColor.red, image: #imageLiteral(resourceName: "elephant"))
    ]

    init(name: String, color: UIColor, image: UIImage? = nil) {
        self.name = name
        self.color = color
        self.image = image
    }
}
