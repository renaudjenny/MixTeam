//
//  PlayerPersistanceTests.swift
//  MixTeam
//
//  Created by Renaud JENNY on 04/08/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import XCTest
@testable import MixTeam

class PlayerPersistanceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()

        // Reset Player data like a fresh installed app
        let players = Player.loadListFromResource()
        Player.save(players: players)
    }

    func testDefaultPlayers() {
        let players = Player.loadList()

        XCTAssertEqual(players.first?.name, "Harry")
    }

    func testSave() {
        let player = Player(name: "Test", image: #imageLiteral(resourceName: "harry-pottar").appImage)

        player.save()

        let players = Player.loadList()
        let lastSavedPlayer = players.last

        XCTAssertEqual(lastSavedPlayer?.name, "Test")
    }

    func testDelete() {
        let players = Player.loadList()

        let firstPlayer = players.first
        XCTAssertEqual(firstPlayer?.name, "Harry")

        firstPlayer?.delete()

        let newPlayers = Player.loadList()

        let newFirstPlayer = newPlayers.first
        XCTAssertEqual(newFirstPlayer?.name, "Amélie")
    }
}
