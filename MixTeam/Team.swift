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
        Team(name: "Blue Koalas", color: UXColor.azure, image: #imageLiteral(resourceName: "elephant")),
        Team(name: "Red Elephants", color: UXColor.red, image: #imageLiteral(resourceName: "elephant")),
        Team(name: "Green Koalas", color: UXColor.jade, image: #imageLiteral(resourceName: "koala"))
    ]

    init(name: String, color: UIColor, image: UIImage? = nil) {
        self.name = name
        self.color = color
        self.image = image
    }
}

extension Team: Hashable {
    var hashValue: Int {
        return self.id.hashValue
    }

    static func ==(lhs: Team, rhs: Team) -> Bool {
        return lhs.id == rhs.id
    }
}
