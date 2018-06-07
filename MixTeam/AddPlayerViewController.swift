//
//  AddPlayerViewController.swift
//  MixTeam
//
//  Created by Renaud JENNY on 07/05/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import UIKit

class AddPlayerViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var validateButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var logoButton: UIButton!

    var player: Player? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        var placeholders = ["John", "Mathilde", "Renaud"]
        var images = [#imageLiteral(resourceName: "harry-pottar"), #imageLiteral(resourceName: "dark-vadir"), #imageLiteral(resourceName: "amalie-poulain"), #imageLiteral(resourceName: "lara-craft"), #imageLiteral(resourceName: "the-botman"), #imageLiteral(resourceName: "wander-woman")]
        
        let randomIndexForName = Int(arc4random_uniform(UInt32(placeholders.count)))
        let randomName = placeholders[randomIndexForName]
        self.nameTextField.text = randomName
        self.titleLabel.text = randomName
        let randomIndexForImage = Int(arc4random_uniform(UInt32(images.count)))
        self.logoButton.setImage(images[randomIndexForImage], for: .normal)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func nameTextFieldEditingChanged() {
        self.titleLabel.text = self.nameTextField.text
    }
    
    @IBAction func validateForm() {
        guard let name = self.nameTextField.text, !name.isEmpty else {
            let alertController = UIAlertController(title: "Give a name", message: "Please, give a name to the player", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alertController, animated: true)
            return
        }

        self.player = Player(name: name, image: self.logoButton.imageView?.image?.appImage)
        self.player?.save()
        
        self.performSegue(withIdentifier: PlayersTableViewController.fromAddPlayerUnwindSegueIdentifier, sender: nil)
    }
}

// MARK: Navigation

extension AddPlayerViewController {
    static let fromLogoCollectionUnwindSegueIdentifier = "AddPlayerViewControllerFromLogoCollectionUnwindSegueIdentifier"

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let playerLogoViewController = segue.destination as? PlayerLogoCollectionViewController {
            playerLogoViewController.selectedImage = self.logoButton.imageView?.image
            playerLogoViewController.mode = .add
        }
    }

    @IBAction func playerLogoUnwind(segue: UIStoryboardSegue) {
        if let playerLogoCollectionViewController = segue.source as? PlayerLogoCollectionViewController {
            self.player?.appImage = playerLogoCollectionViewController.selectedImage?.appImage
            self.logoButton.setImage(playerLogoCollectionViewController.selectedImage, for: .normal)
        }
    }
}

// MARK: - Text Field

extension AddPlayerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nameTextField.resignFirstResponder()
        return true
    }
}

// MARK: - Scroll View

extension AddPlayerViewController {
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }

    @objc func keyboardWillShow(notification: Notification) {
        self.adjustInsetForKeyboard(isShown: true, notification: notification)
    }

    @objc func keyboardWillHide(notification: Notification) {
        self.adjustInsetForKeyboard(isShown: false, notification: notification)
    }

    func adjustInsetForKeyboard(isShown: Bool, notification: Notification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrameInfo = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue
        let keyboardFrame = keyboardFrameInfo?.cgRectValue ?? CGRect()
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let adjustmentHeight = (keyboardFrame.height + statusBarHeight) * (isShown ? 1 : -1)
        self.scrollView.contentInset.bottom += adjustmentHeight
        self.scrollView.scrollIndicatorInsets.bottom += adjustmentHeight
    }
}
