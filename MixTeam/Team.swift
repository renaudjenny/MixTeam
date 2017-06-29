//
//  Team.swift
//  MixTeam
//
//  Created by Renaud JENNY on 17/05/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import UIKit

class Team {
    var id = UUID()
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

    init?(dictionary: [String: Any]) {
        guard let idString = dictionary["id"] as? String, let id = UUID(uuidString: idString),
            let name = dictionary["name"] as? String,
            let colorString = dictionary["color"] as? String,
            let imageString = dictionary["image"] as? String, let image = UIImage(with: imageString) else {
                return nil
        }

        self.id = id
        self.name = name
        self.color = UXColor.fromString(colorString: colorString)
        self.image = image
    }

    func toDictionary() -> [String: Any] {
        return [
            "id": self.id.uuidString,
            "name": self.name,
            "color": self.color.UXColorString,
            "image": self.image?.UXImageString ?? "unknown image"
        ]
    }

    class func initList(teamsJson: [[String: Any]]) -> [Team] {
        var teams: [Team] = []
        for teamDictionary in teamsJson {
            if let team = Team(dictionary: teamDictionary) {
                teams.append(team)
            }
        }
        return teams
    }

    static let teamsResourcePath = "teams"

    func saveList() throws {
        let json = try JSONSerialization.data(withJSONObject: self.toDictionary(), options: .prettyPrinted)
    }

    class func loadList() -> [Team] {
        guard let path = Bundle.main.path(forResource: Team.teamsResourcePath, ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
            let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let json = jsonObject?["teams"] as? [[String: Any]] else {
                return []
        }

        return Team.initList(teamsJson: json)
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
