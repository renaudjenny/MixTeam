//
//  EditTeamViewController.swift
//  MixTeam
//
//  Created by Renaud JENNY on 19/07/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import UIKit

class EditTeamViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var logoButton: UIButton!
    @IBOutlet weak var colorCollectionView: UICollectionView!

    var team: Team? = nil
    var colors = UXColor.allColors

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let team = self.team else {
            return
        }

        self.titleLabel.text = team.name
        self.nameTextField.text = team.name
        self.logoButton.setImage(team.image?.image.tint(with: team.color.color), for: .normal)
        self.logoButton.accessibilityIdentifier = team.image?.rawValue
        self.logoButton.backgroundColor = team.color.color.withAlphaComponent(0.10)
    }

    @IBAction func validateForm() {
        guard let name = self.nameTextField.text, !name.isEmpty else {
            let alertController = UIAlertController(title: "Give a name", message: "Please, give a name to the team", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alertController, animated: true)
            return
        }

        self.team?.name = name
        self.team?.update()

        self.performSegue(withIdentifier: TeamsTableViewController.fromEditTeamUnwindSegueIdentifier, sender: nil)
    }

    @IBAction func cancelForm() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Navigation

extension EditTeamViewController {
    static let fromLogoColletionSegueIdentifier = "EditTeamViewControllerFromLogoColletionSegueIdentifier"

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let teamLogoViewController = segue.destination as? TeamLogoCollectionViewController {
            teamLogoViewController.selectedImage = self.team?.image?.image
        }
    }

    @IBAction func teamLogoUnwind(segue: UIStoryboardSegue) {
        if let teamLogoCollectionViewController = segue.source as? TeamLogoCollectionViewController {
            self.team?.image = teamLogoCollectionViewController.selectedImage?.appImage
            let tintedImage = self.team?.image?.image.tint(with: self.team?.color.color ?? .gray)

            self.logoButton.setImage(tintedImage, for: .normal)
            self.logoButton.accessibilityIdentifier = self.team?.image?.rawValue
        }
    }
}

extension EditTeamViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    static let colorColoctionCellIdentifier = "EditTeamViewControllerColorColoctionCellIdentifier"

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditTeamViewController.colorColoctionCellIdentifier, for: indexPath)

        let colorView = UIView()
        colorView.translatesAutoresizingMaskIntoConstraints = false
        let color = colors[indexPath.row]
        colorView.backgroundColor = color.color
        colorView.layer.cornerRadius = 5.0
        colorView.layer.borderColor = UIColor.black.cgColor
        colorView.layer.borderWidth = 1.0
        cell.addSubview(colorView)

        cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[colorView]|", options: [], metrics: nil, views: ["colorView": colorView]))
        cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[colorView]|", options: [], metrics: nil, views: ["colorView": colorView]))

        cell.isAccessibilityElement = true
        cell.accessibilityLabel = color.rawValue

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.team?.color = self.colors[indexPath.row]
        let tintedLogoImage = self.team?.image?.image.tint(with: self.team?.color.color ?? .gray)
        self.logoButton.setImage(tintedLogoImage, for: .normal)
        self.logoButton.backgroundColor = self.team?.color.color.withAlphaComponent(0.10)
    }
}

extension EditTeamViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nameTextField.resignFirstResponder()
        return true
    }

    @IBAction func nameTextFieldEditingChanged() {
        self.titleLabel.text = self.nameTextField.text
    }
}
