//
//  Player.swift
//  MixTeam
//
//  Created by Renaud JENNY on 07/05/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import UIKit

class Player: NSObject {
    var name: String = ""
    var image: UIImage? = nil
    
    // FIXME: replace by a database system
    static var players: [Player] = []
    
    init(name: String, image: UIImage?) {
        super.init()
        self.name = name
        self.image = image
    }
}
