//
//  TeamsPersistenceTests.swift
//  MixTeam
//
//  Created by Renaud JENNY on 13/07/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import XCTest
@testable import MixTeam

class TeamsPersistenceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()

        // Reset Team data like a fresh installed app
        let teams = Team.loadListFromResource()
        Team.save(teams: teams)
    }

    func testDefaultTeams() {
        let teams = Team.loadList()

        XCTAssertEqual(teams.first?.name, "Purple Elephants")
    }

    func testSave() {
        let team = Team(name: "Test", color: UXColor.jade, image: #imageLiteral(resourceName: "elephant"))

        team.save()

        let teams = Team.loadList()
        let lastSavedTeam = teams.last

        XCTAssertEqual(lastSavedTeam?.name, "Test")
    }

    func testDelete() {
        let teams = Team.loadList()

        let firstTeam = teams.first
        XCTAssertEqual(firstTeam?.name, "Purple Elephants")

        firstTeam?.delete()

        let newTeams = Team.loadList()

        let newFirstTeam = newTeams.first
        XCTAssertEqual(newFirstTeam?.name, "Red Koalas")
    }
}
