//
//  AddTeamViewController.swift
//  MixTeam
//
//  Created by Renaud JENNY on 17/05/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import UIKit

class AddTeamViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var logoButton: UIButton!
    @IBOutlet weak var colorCollectionView: UICollectionView!

    var colors = UXColor.allColors()
    var addTeamAction: ((Team) -> Void)?
    var selectedColor = UIColor.gray
    var selectedImage: UIImage? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        let placeholders = ["Yellow Elephants", "Orange Koalas", "Red Pandas"]
        let images = [#imageLiteral(resourceName: "elephant"), #imageLiteral(resourceName: "koala"), #imageLiteral(resourceName: "panda")]

        let randomIndex = Int(arc4random_uniform(UInt32(placeholders.count)))
        self.nameTextField.text = placeholders[randomIndex]
        self.selectedImage = images[randomIndex]
        self.logoButton.setImage(self.selectedImage, for: .normal)
        if let selectedColor = self.colorCollectionView.cellForItem(at: IndexPath(index: randomIndex))?.backgroundColor {
            self.selectedColor = selectedColor
        }

        self.logoButton.layer.cornerRadius = 5.0
    }
    
    @IBAction func validateForm() {
        defer {
            self.navigationController?.popViewController(animated: true)
        }

        guard let text = self.nameTextField.text, let selectedImage = self.selectedImage else {
            return
        }

        let team = Team(name: text, color: self.selectedColor, image: selectedImage)
        team.save()

        self.addTeamAction?(team)
        if let playersTableViewController = self.playersTableViewController {
            playersTableViewController.teams.append(team)
            playersTableViewController.tableView.reloadData()
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO
    }
}

private let kAddTeamViewControllerCollectionViewCellIdentifier: String = "addTeamViewControllerCollectionViewCellIdentifier"

extension AddTeamViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kAddTeamViewControllerCollectionViewCellIdentifier, for: indexPath)

        let colorView = UIView()
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.backgroundColor = colors[indexPath.row]
        colorView.layer.cornerRadius = 5.0
        colorView.layer.borderColor = UIColor.black.cgColor
        colorView.layer.borderWidth = 1.0
        cell.addSubview(colorView)
        
        cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[colorView]|", options: [], metrics: nil, views: ["colorView": colorView]))
        cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[colorView]|", options: [], metrics: nil, views: ["colorView": colorView]))

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedColor = self.colors[indexPath.row]
        self.selectedImage = self.logoButton.imageView?.image
        let tintedLogoImage = self.selectedImage?.tint(with: self.selectedColor)
        self.logoButton.setImage(tintedLogoImage, for: .normal)
        self.logoButton.backgroundColor = self.selectedColor.withAlphaComponent(0.10)
    }
}

extension AddTeamViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nameTextField.resignFirstResponder()
        return true
    }
}
