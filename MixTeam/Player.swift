//
//  Player.swift
//  MixTeam
//
//  Created by Renaud JENNY on 07/05/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import UIKit
import SwiftUI

struct Player: Codable, Identifiable, Hashable {
    let id = UUID()
    var name: String = ""
    var imageIdentifier: ImageIdentifier
}
