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

    var addPlayerAction: ((Player) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        var placeholders = ["John", "Mathilde", "Renaud"]
        var images = [#imageLiteral(resourceName: "harry-pottar"), #imageLiteral(resourceName: "dark-vadir"), #imageLiteral(resourceName: "amalie-poulain"), #imageLiteral(resourceName: "lara-craft")]
        
        let randomIndexForName = Int(arc4random_uniform(UInt32(placeholders.count)))
        self.nameTextField.text = placeholders[randomIndexForName]
        let randomIndexForImage = Int(arc4random_uniform(UInt32(images.count)))
        self.logoButton.setImage(images[randomIndexForImage], for: .normal)
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
        let player = Player(name: playerName, image: self.logoButton.imageView?.image)
        Player.players.append(player)
        
        self.navigationController?.popViewController(animated: true)
        self.addPlayerAction?(player)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let playerLogoCollectionViewController = segue.destination as? PlayerLogoCollectionViewController {
            playerLogoCollectionViewController.selectedImage = self.logoButton.imageView?.image
            playerLogoCollectionViewController.onSelectedImageAction = { (image) in
                self.logoButton.setImage(image, for: .normal)
            }
        }
    }
}

extension AddPlayerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nameTextField.resignFirstResponder()
        return true
    }
}
