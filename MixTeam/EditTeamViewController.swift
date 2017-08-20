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
    var colors = UXColor.allColors()
    var selectedColor = UIColor.gray
    var selectedImage: UIImage? = nil
    var editTeamAction: ((Team) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let team = self.team else {
            return
        }

        self.titleLabel.text = team.name
        self.nameTextField.text = team.name
        self.selectedImage = team.image
        self.selectedColor = team.color
        self.logoButton.setImage(team.image?.tint(with: team.color), for: .normal)
        self.logoButton.accessibilityIdentifier = team.image?.appImage.rawValue
        self.logoButton.backgroundColor = team.color.withAlphaComponent(0.10)
    }

    @IBAction func validateForm() {
        defer {
            self.dismiss(animated: true, completion: nil)
        }

        guard let team = self.team else {
            return
        }

        team.name = self.nameTextField.text ?? "ERROR"
        team.image = self.selectedImage
        team.color = self.selectedColor

        team.update()

        self.editTeamAction?(team)

        if let playersTableViewController = self.playersTableViewController {
            guard let index = playersTableViewController.teams.index(where: { $0 == team }) else {
                return
            }

            team.players = playersTableViewController.teams[index].players
            playersTableViewController.teams[index] = team
            playersTableViewController.tableView.reloadData()
        }
    }

    @IBAction func cancelForm() {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch segue.destination {
        case let viewController as TeamLogoCollectionViewController:
            viewController.selectedImage = self.selectedImage
            viewController.onSelectedImageAction = { (image) -> Void in
                self.selectedImage = image
                let tintedImage = image?.tint(with: self.selectedColor)

                self.logoButton.setImage(tintedImage, for: .normal)
                self.logoButton.accessibilityIdentifier = image?.appImage.rawValue
            }
        default: break
        }
    }
}

private let kEditTeamViewControllerCollectionViewCellIdentifier: String = "editTeamViewControllerCollectionViewCellIdentifier"

extension EditTeamViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kEditTeamViewControllerCollectionViewCellIdentifier, for: indexPath)

        let colorView = UIView()
        colorView.translatesAutoresizingMaskIntoConstraints = false
        let color = colors[indexPath.row]
        colorView.backgroundColor = color
        colorView.layer.cornerRadius = 5.0
        colorView.layer.borderColor = UIColor.black.cgColor
        colorView.layer.borderWidth = 1.0
        cell.addSubview(colorView)

        cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[colorView]|", options: [], metrics: nil, views: ["colorView": colorView]))
        cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[colorView]|", options: [], metrics: nil, views: ["colorView": colorView]))

        cell.isAccessibilityElement = true
        cell.accessibilityLabel = color.UXColorString

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedColor = self.colors[indexPath.row]
        let tintedLogoImage = self.selectedImage?.tint(with: self.selectedColor)
        self.logoButton.setImage(tintedLogoImage, for: .normal)
        self.logoButton.backgroundColor = self.selectedColor.withAlphaComponent(0.10)
    }
}

extension EditTeamViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nameTextField.resignFirstResponder()
        return true
    }
}
