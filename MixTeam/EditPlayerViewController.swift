//
//  EditPlayerViewController.swift
//  MixTeam
//
//  Created by Renaud JENNY on 07/05/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import UIKit

class EditPlayerViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var logoButton: UIButton!
    
    var player: Player? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let player = self.player else {
            return
        }
        
        self.titleLabel.text = player.name
        self.nameTextField.text = player.name
        self.logoButton.setImage(player.appImage?.image, for: .normal)

        self.addKeyboardObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func validateForm() {
        guard let name = self.nameTextField.text, !name.isEmpty else {
            let alertController = UIAlertController(title: "Give a name", message: "Please, give a name to the player", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alertController, animated: true)
            return
        }

        self.player?.name = name
        self.player?.update()

        self.performSegue(withIdentifier: PlayersTableViewController.fromEditPlayerUnwindSegueIdentifier, sender: nil)
    }
    
    @IBAction func cancelForm() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Navigation

extension EditPlayerViewController {
    static let fromLogoCollectionUnwindSegueIdentifier = "EditPlayerViewControllerFromLogoCollectionUnwindSegueIdentifier"

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let playerLogoViewController = segue.destination as? PlayerLogoCollectionViewController {
            self.nameTextField.resignFirstResponder()
            playerLogoViewController.selectedImage = self.logoButton.imageView?.image
            playerLogoViewController.mode = .edit
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

extension EditPlayerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nameTextField.resignFirstResponder()
        return true
    }

    @IBAction func nameTextFieldEditingChanged() {
        self.titleLabel.text = self.nameTextField.text
    }
}

// MARK: - Scroll View

extension EditPlayerViewController {
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: Notification) {
        self.adjustInsetForKeyboard(isShown: true, notification: notification)
    }

    @objc func keyboardWillHide(notification: Notification) {
        self.adjustInsetForKeyboard(isShown: false, notification: notification)
    }

    func adjustInsetForKeyboard(isShown: Bool, notification: Notification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrameInfo = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue
        let keyboardFrame = keyboardFrameInfo?.cgRectValue ?? CGRect()
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let adjustmentHeight = (keyboardFrame.height + statusBarHeight) * (isShown ? 1 : -1)
        self.scrollView.contentInset.bottom += adjustmentHeight
        self.scrollView.scrollIndicatorInsets.bottom += adjustmentHeight
    }
}
