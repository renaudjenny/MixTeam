//
//  EditPlayerViewController.swift
//  MixTeam
//
//  Created by Renaud JENNY on 07/05/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import UIKit

class EditPlayerViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var logoImageView: UIImageView!
    
    var player: Player? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let player = player else {
            return
        }
        
        titleLabel.text = player.name
        nameTextField.text = player.name
        logoImageView.image = player.image
    }
    
    @IBAction func validateForm() {
        defer {
            self.dismiss(animated: true, completion: nil)
        }
        
        let optionalPlayer = Player.players.first { (player) -> Bool in
            player.name == self.player?.name
        }
        
        guard let player = optionalPlayer else {
            // TODO: error message
            return
        }
        
        player.name = self.nameTextField.text ?? "ERROR"
        player.image = self.logoImageView.image
    }
    
    @IBAction func cancelForm() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension EditPlayerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nameTextField.resignFirstResponder()
        return true
    }
}
