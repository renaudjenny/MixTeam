//
//  Team.swift
//  MixTeam
//
//  Created by Renaud JENNY on 17/05/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import UIKit

struct Team: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String = ""
    var colorIdentifier: ColorIdentifier = .gray
    var imageIdentifier: ImageIdentifier = .unknown
    var players: [Player] = []

    init(name: String, colorIdentifier: ColorIdentifier, imageIdentifier: ImageIdentifier) {
        self.name = name
        self.colorIdentifier = colorIdentifier
        self.imageIdentifier = imageIdentifier
    }
}
