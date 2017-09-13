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
    var editPlayerAction: ((Player) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let player = self.player else {
            return
        }
        
        self.titleLabel.text = player.name
        self.nameTextField.text = player.name
        self.logoButton.setImage(player.image, for: .normal)

        self.addKeyboardObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
            self.nameTextField.resignFirstResponder()
            viewController.selectedImage = self.logoButton.imageView?.image
            viewController.onSelectedImageAction = { (image) -> Void in
                self.logoButton.setImage(image, for: .normal)
            }
        default: break
        }
    }
}

// MARK: - Text Field

extension EditPlayerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nameTextField.resignFirstResponder()
        return true
    }
}

// MARK: - Scroll View

extension EditPlayerViewController {
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }

    func keyboardWillShow(notification: Notification) {
        self.adjustInsetForKeyboard(isShown: true, notification: notification)
    }

    func keyboardWillHide(notification: Notification) {
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
