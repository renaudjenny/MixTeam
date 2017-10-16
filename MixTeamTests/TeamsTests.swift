//
//  TeamsTests.swift
//  MixTeam
//
//  Created by Renaud JENNY on 12/07/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import XCTest
@testable import MixTeam

class TeamsTests: XCTestCase {
    func testInit() {
        let team = Team(name: "Test", color: UXColor.jade, image: #imageLiteral(resourceName: "elephant").appImage)
        XCTAssertEqual(team.name, "Test")
    }
}
