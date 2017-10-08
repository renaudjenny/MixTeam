//
//  PlayerTests.swift
//  MixTeam
//
//  Created by Renaud JENNY on 12/06/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import XCTest
@testable import MixTeam

class PlayerTests: XCTestCase {

    func testInit() {
        let player = Player(name: "Test", image: #imageLiteral(resourceName: "harry-pottar").appImage)
        XCTAssertEqual(player.name, "Test")
    }

    func testOperators() {
        let player1 = Player(name: "Test", image: nil)
        let player2 = Player(name: "Test", image: nil)

        XCTAssertFalse(player1 == player2)

        let array1 = [player1]
        let array2 = [player1]

        guard let first1 = array1.first, let first2 = array2.first else {
            fatalError()
        }
        XCTAssertEqual(first1, first2)
    }
}
