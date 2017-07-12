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

    init(name: String, color: UIColor, image: UIImage? = nil) {
        self.name = name
        self.color = color
        self.image = image
    }

    init?(dictionary: [String: Any]) {
        guard let idString = dictionary["id"] as? String, let id = UUID(uuidString: idString),
            let name = dictionary["name"] as? String,
            let colorString = dictionary["color"] as? String else {
                return nil
        }

        self.id = id
        self.name = name
        self.color = UXColor.fromString(colorString: colorString)

        if let imageString = dictionary["image"] as? String, let image = UIImage(with: imageString) {
            self.image = image
        }
    }

    func toDictionary() -> [String: Any] {
        return [
            "id": self.id.uuidString,
            "name": self.name,
            "color": self.color.UXColorString,
            "image": self.image?.UXImageString ?? "unknown image"
        ]
    }

    class func initList(teamsJSON: [[String: Any]]) -> [Team] {
        var teams: [Team] = []
        for teamDictionary in teamsJSON {
            if let team = Team(dictionary: teamDictionary) {
                teams.append(team)
            }
        }
        return teams
    }

    static let teamsResourcePath = "teams"
    static let teamsJSONStringKey = "teamsJSONString"

    func save() {
        var teams = Team.loadList()
        teams.append(self)
        Team.save(teams: teams)
    }

    class func save(teams: [Team]) {
        var arrayOfTeams: [[String: Any]] = []
        for team in teams {
            arrayOfTeams.append(team.toDictionary())
        }

        guard let json = try? JSONSerialization.data(withJSONObject: ["teams": arrayOfTeams], options: .prettyPrinted),
            let jsonString = String(data: json, encoding: .utf8) else {
                fatalError("Cannot save Teams JSON")
        }

        UserDefaults.standard.set(jsonString, forKey: Team.teamsJSONStringKey)
    }

    class func loadList() -> [Team] {
        guard let teamsJSONString = UserDefaults.standard.string(forKey: Team.teamsJSONStringKey),
            let data = teamsJSONString.data(using: .utf8),
            let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let json = jsonObject?["teams"] as? [[String: Any]] else {
            return []
        }

        return Team.initList(teamsJSON: json)
    }

    class func loadListFromResource() -> [Team] {
        guard let path = Bundle.main.path(forResource: Team.teamsResourcePath, ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
            let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let json = jsonObject?["teams"] as? [[String: Any]] else {
                return []
        }

        return Team.initList(teamsJSON: json)
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
