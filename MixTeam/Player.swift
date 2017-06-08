//
//  Player.swift
//  MixTeam
//
//  Created by Renaud JENNY on 07/05/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import UIKit

class Player {
    let id = UUID()
    var name: String = ""
    var image: UIImage? = nil
    var handicap: Int = 100
    
    // FIXME: replace by a database system
    static var players: [Player] = [
        Player(name: "Renaud", image: #imageLiteral(resourceName: "harry-pottar")),
        Player(name: "Mathilde", image: #imageLiteral(resourceName: "amalie-poulain")),
        Player(name: "Dark Lord", image: #imageLiteral(resourceName: "dark-vadir")),
        Player(name: "Milena", image: #imageLiteral(resourceName: "lara-craft"))
    ]
    
    init(name: String, image: UIImage?) {
        self.name = name
        self.image = image
    }
}

extension Player: Equatable {
    static func ==(lhs: Player, rhs: Player) -> Bool {
        return lhs.id == rhs.id
    }
}
