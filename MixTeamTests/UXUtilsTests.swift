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
        let colors = UXColor.allColors()
        XCTAssertTrue(colors.contains(UXColor.yellow))
    }
}
