//
//  Player.swift
//  MixTeam
//
//  Created by Renaud JENNY on 07/05/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import UIKit

class Player: Codable {
    let id = UUID()
    var name: String = ""
    var appImage: AppImage
    var handicap: Int = 100

    init(name: String = "", image: AppImage? = nil) {
        self.name = name
        self.appImage = image ?? AppImage.unknown
    }
}

struct Players: Codable {
    let players: [Player]
}

// MARK: - Persistance

extension Player {
    static let playersResourcePath = "players"
    static let playersJSONStringKey = "playersJSONString"

    func save() {
        var players = Player.loadList()
        players.append(self)
        Player.save(players: players)
    }

    class func save(players: [Player]) {
        guard let data = try? JSONEncoder().encode(Players(players: players)),
            let jsonString = String(data: data, encoding: .utf8) else {
                fatalError("Cannot save Players JSON")
        }

        UserDefaults.standard.set(jsonString, forKey: Player.playersJSONStringKey)
    }

    class func loadList() -> [Player] {
        guard let playersJSONString = UserDefaults.standard.string(forKey: Player.playersJSONStringKey),
            let jsonData = playersJSONString.data(using: .utf8),
            let playersContainer = try? JSONDecoder().decode(Players.self, from: jsonData) else {
            return []
        }

        return playersContainer.players
    }

    class func loadListFromResource() -> [Player] {
        guard let path = Bundle.main.path(forResource: Player.playersResourcePath, ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
            let playersContainer = try? JSONDecoder().decode(Players.self, from: data) else {
                return []
        }

        return playersContainer.players
    }

    func delete() {
        var players = Player.loadList()
        players = players.filter { $0 != self }

        Player.save(players: players)
    }

    func update() {
        var players = Player.loadList()
        guard let index = players.firstIndex(where: { $0 == self }) else {
            // Player not exist yet, save it instead
            self.save()
            return
        }
        
        players[index] = self
        Player.save(players: players)
    }
}

extension Player: Identifiable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.id == rhs.id
    }
}
