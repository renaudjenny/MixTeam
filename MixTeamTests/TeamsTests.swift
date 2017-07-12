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
        let team = Team(name: "Test", color: UXColor.jade, image: #imageLiteral(resourceName: "elephant"))
        XCTAssertEqual(team.name, "Test")
    }

    func testInitWithDictionary() {
        guard let team = Team(dictionary: [
            "id": "C0CA70AD-0619-43F4-AEED-ECD094BADEDB",
            "name": "Test",
            "color": "red",
            "image": "elephant"]) else {
                XCTFail("Cannot init team with dictionary")
                return
        }

        XCTAssertEqual(team.id, UUID(uuidString: "C0CA70AD-0619-43F4-AEED-ECD094BADEDB"))
        XCTAssertEqual(team.name, "Test")
        XCTAssertEqual(team.color, UXColor.red)
        XCTAssertEqual(team.image?.UXImageString, "elephant")
    }

    func testInitNilWithDictionary() {
        let team = Team(dictionary: [
            "id": "C0CA70AD-0619-43F4-AEED-ECD094BADEDB",
            "color": "red",
            "image": "elephant"])

        XCTAssertNil(team)
    }

    func testToDictionary() {
        guard let team = Team(dictionary: [
            "id": "C0CA70AD-0619-43F4-AEED-ECD094BADEDB",
            "name": "Test",
            "color": "red",
            "image": "elephant"]) else {
                XCTFail("Cannot init team with dictionary")
                return
        }

        let dictionary = team.toDictionary()

        XCTAssertEqual(dictionary["id"] as? String, "C0CA70AD-0619-43F4-AEED-ECD094BADEDB")
        XCTAssertEqual(dictionary["name"] as? String, "Test")
        XCTAssertEqual(dictionary["color"] as? String, "red")
        XCTAssertEqual(dictionary["image"] as? String, "elephant")
    }
}
