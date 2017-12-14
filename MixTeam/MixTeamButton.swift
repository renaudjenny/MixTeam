//
//  MixTeamButton.swift
//  MixTeam
//
//  Created by Renaud JENNY on 28/10/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import UIKit

@IBDesignable
class MixTeamButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    private func setup() {
        self.backgroundColor = UXColor.red.color
    }
}
