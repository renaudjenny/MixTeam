//
//  UXUtilsTests.swift
//  MixTeam
//
//  Created by Renaud JENNY on 12/06/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import XCTest
@testable import MixTeam

class UXUtilsTests: XCTestCase {
    
    func testUXColorsAllColors() {
        let colors = UXColor.allColors
        XCTAssertTrue(colors.contains(UXColor.yellow))
    }

    func testAppImage() {
        XCTAssertEqual(AppImage.unknown.rawValue, "unknown image")
        XCTAssertEqual(AppImage.unknown.image, #imageLiteral(resourceName: "unknown"))
        XCTAssertEqual(#imageLiteral(resourceName: "unknown").appImage, AppImage.unknown)

        XCTAssertEqual(AppImage.elephant.rawValue, "elephant")
        XCTAssertEqual(AppImage.elephant.image, #imageLiteral(resourceName: "elephant"))
        XCTAssertEqual(#imageLiteral(resourceName: "elephant").appImage, AppImage.elephant)

        XCTAssertEqual(AppImage.koala.rawValue, "koala")
        XCTAssertEqual(AppImage.koala.image, #imageLiteral(resourceName: "koala"))
        XCTAssertEqual(#imageLiteral(resourceName: "koala").appImage, AppImage.koala)

        XCTAssertEqual(AppImage.panda.rawValue, "panda")
        XCTAssertEqual(AppImage.panda.image, #imageLiteral(resourceName: "panda"))
        XCTAssertEqual(#imageLiteral(resourceName: "panda").appImage, AppImage.panda)

        XCTAssertEqual(AppImage.octopus.rawValue, "octopus")
        XCTAssertEqual(AppImage.octopus.image, #imageLiteral(resourceName: "octopus"))
        XCTAssertEqual(#imageLiteral(resourceName: "octopus").appImage, AppImage.octopus)

        XCTAssertEqual(AppImage.lion.rawValue, "lion")
        XCTAssertEqual(AppImage.lion.image, #imageLiteral(resourceName: "lion"))
        XCTAssertEqual(#imageLiteral(resourceName: "lion").appImage, AppImage.lion)

        XCTAssertEqual(AppImage.harryPottar.rawValue, "harry-pottar")
        XCTAssertEqual(AppImage.harryPottar.image, #imageLiteral(resourceName: "harry-pottar"))
        XCTAssertEqual(#imageLiteral(resourceName: "harry-pottar").appImage, AppImage.harryPottar)

        XCTAssertEqual(AppImage.amaliePoulain.rawValue, "amalie-poulain")
        XCTAssertEqual(AppImage.amaliePoulain.image, #imageLiteral(resourceName: "amalie-poulain"))
        XCTAssertEqual(#imageLiteral(resourceName: "amalie-poulain").appImage, AppImage.amaliePoulain)

        XCTAssertEqual(AppImage.darkVadir.rawValue, "dark-vadir")
        XCTAssertEqual(AppImage.darkVadir.image, #imageLiteral(resourceName: "dark-vadir"))
        XCTAssertEqual(#imageLiteral(resourceName: "dark-vadir").appImage, AppImage.darkVadir)

        XCTAssertEqual(AppImage.laraCraft.rawValue, "lara-craft")
        XCTAssertEqual(AppImage.laraCraft.image, #imageLiteral(resourceName: "lara-craft"))
        XCTAssertEqual(#imageLiteral(resourceName: "lara-craft").appImage, AppImage.laraCraft)

        XCTAssertEqual(AppImage.wanderWoman.rawValue, "wander-woman")
        XCTAssertEqual(AppImage.wanderWoman.image, #imageLiteral(resourceName: "wander-woman"))
        XCTAssertEqual(#imageLiteral(resourceName: "wander-woman").appImage, AppImage.wanderWoman)

        XCTAssertEqual(AppImage.theBotman.rawValue, "the-botman")
        XCTAssertEqual(AppImage.theBotman.image, #imageLiteral(resourceName: "the-botman"))
        XCTAssertEqual(#imageLiteral(resourceName: "the-botman").appImage, AppImage.theBotman)

        XCTAssertEqual(#imageLiteral(resourceName: "teams").appImage, AppImage.unknown)
    }
}
