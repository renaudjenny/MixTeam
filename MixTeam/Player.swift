//
//  Player.swift
//  MixTeam
//
//  Created by Renaud JENNY on 07/05/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import UIKit

class Player {

    var id = UUID()
    var name: String = ""
    var image: UIImage? = nil
    var handicap: Int = 100
    
    init(name: String, image: UIImage?) {
        self.name = name
        self.image = image
    }

    //MARK: - Persistance

    static let playersResourcePath = "players"
    static let playersJSONStringKey = "playersJSONString"

    init?(dictionary: [String: Any]) {
        guard let idString = dictionary["id"] as? String, let id = UUID(uuidString: idString),
            let name = dictionary["name"] as? String,
            let handicap = dictionary["handicap"] as? Int else {
                return nil
        }

        self.id = id
        self.name = name
        self.handicap = handicap

        if let imageString = dictionary["image"] as? String, let image = UIImage(with: imageString) {
            self.image = image
        }
    }

    func toDictionary() -> [String: Any] {
        return [
            "id": self.id.uuidString,
            "name": self.name,
            "image": self.image?.UXImageString ?? "unknown image",
            "handicap": self.handicap
        ]
    }

    class func initList(playersJSON: [[String: Any]]) -> [Player] {
        var players: [Player] = []
        for playerDictionary in playersJSON {
            if let player = Player(dictionary: playerDictionary) {
                players.append(player)
            }
        }
        return players
    }

    func save() {
        var players = Player.loadList()
        players.append(self)
        Player.save(players: players)
    }

    class func save(players: [Player]) {
        var arrayOfPlayers: [[String: Any]] = []
        for player in players {
            arrayOfPlayers.append(player.toDictionary())
        }

        guard let json = try? JSONSerialization.data(withJSONObject: ["players": arrayOfPlayers], options: .prettyPrinted),
            let jsonString = String(data: json, encoding: .utf8) else {
                fatalError("Cannot save Players JSON")
        }

        UserDefaults.standard.set(jsonString, forKey: Player.playersJSONStringKey)
    }

    class func loadList() -> [Player] {
        guard let playersJSONString = UserDefaults.standard.string(forKey: Player.playersJSONStringKey),
            let data = playersJSONString.data(using: .utf8),
            let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let json = jsonObject?["players"] as? [[String: Any]] else {
                return []
        }

        return Player.initList(playersJSON: json)
    }

    class func loadListFromResource() -> [Player] {
        guard let path = Bundle.main.path(forResource: Player.playersResourcePath, ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
            let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let json = jsonObject?["players"] as? [[String: Any]] else {
                return []
        }

        return Player.initList(playersJSON: json)
    }

    func delete() {
        var players = Player.loadList()
        players = players.filter { $0 != self }

        Player.save(players: players)
    }

    func update() {
        var players = Player.loadList()
        guard let index = players.index(where: { $0 == self }) else {
            // Player not exist yet, save it instead
            self.save()
            return
        }

        players[index] = self
        Player.save(players: players)
    }
}

extension Player: Equatable {
    static func ==(lhs: Player, rhs: Player) -> Bool {
        return lhs.id == rhs.id
    }
}
