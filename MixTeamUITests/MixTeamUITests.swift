//
//  MixTeamUITests.swift
//  MixTeamUITests
//
//  Created by Renaud JENNY on 07/05/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import XCTest

class MixTeamUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    func testAddTeam() {
        let app = XCUIApplication()
        app.tabBars.buttons["Teams"].tap()
        app.navigationBars["Teams"].buttons["Add"].tap()

        let teamLogoButton = app.buttons["Team Logo"]
        teamLogoButton.tap()

        app.buttons["koala"].tap()
        XCTAssertEqual(teamLogoButton.value as? String, "koala")

        app.buttons["red color"].tap()

        let yourTeamNameTextField = app.textFields["Name"]
        yourTeamNameTextField.tap()
        yourTeamNameTextField.typeText("Red Koalas\n")
        app.buttons["Create Team"].tap()
    }
}
