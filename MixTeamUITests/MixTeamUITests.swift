import XCTest

class MixTeamUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    func testAddTeam() {
        let app = XCUIApplication()

        app.swipeUp()
        app.swipeUp()

        app.buttons["Add a new Team"].tap()

        app.buttons["Edit Team Lilac Elephant"].tap()

        app.buttons["koala"].tap()

        app.buttons["Strawberry color"].tap()

        let yourTeamNameTextField = app.textFields["Edit"]
        yourTeamNameTextField.tap()

        for _ in 0..<"Lilac Elephant".count {
            yourTeamNameTextField.typeText(XCUIKeyboardKey.delete.rawValue)
        }

        yourTeamNameTextField.typeText("Strawberry Koalas\n")
        app.buttons["Done"].tap()
    }
}
