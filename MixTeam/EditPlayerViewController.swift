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
    @IBOutlet weak var logoButton: UIButton!
    
    var player: Player? = nil
    var editPlayerAction: ((Player) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let player = self.player else {
            return
        }
        
        self.titleLabel.text = player.name
        self.nameTextField.text = player.name
        self.logoButton.setImage(player.image, for: .normal)
    }
    
    @IBAction func validateForm() {
        defer {
            self.dismiss(animated: true, completion: nil)
        }
        
        guard let player = self.player else {
            // TODO: error message
            return
        }
        
        player.name = self.nameTextField.text ?? "ERROR"
        player.image = self.logoButton.imageView?.image
        player.update()

        self.editPlayerAction?(player)
    }
    
    @IBAction func cancelForm() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch segue.destination {
        case let viewController as PlayerLogoCollectionViewController:
            viewController.selectedImage = self.logoButton.imageView?.image
            viewController.onSelectedImageAction = { (image) -> Void in
                self.logoButton.setImage(image, for: .normal)
            }
        default: break
        }
    }
}

extension EditPlayerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nameTextField.resignFirstResponder()
        return true
    }
}
