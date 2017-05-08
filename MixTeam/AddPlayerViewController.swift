//
//  AddPlayerViewController.swift
//  MixTeam
//
//  Created by Renaud JENNY on 07/05/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import UIKit

class AddPlayerViewController: UIViewController {
    @IBOutlet weak var validateButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var logoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var placeholders = ["John", "Mathilde", "Renaud"]
        
        let randomIndex = Int(arc4random_uniform(UInt32(placeholders.count)))
        self.nameTextField.text = placeholders[randomIndex]
    }
    
    @IBAction func nameTextFieldDone() {
        // FIXME: Do Something?
    }
    
    @IBAction func validateForm() {
        var playerName = ""
        
        // TODO: check if player name is valid:
        // * player name not already exist
        // * not empty string
        playerName = nameTextField.text ?? "ERROR"
        Player.players.append(Player(name: playerName, image: self.logoButton.imageView?.image))
        
        self.navigationController?.popViewController(animated: true)
    }
}

extension AddPlayerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nameTextField.resignFirstResponder()
        return true
    }
}
