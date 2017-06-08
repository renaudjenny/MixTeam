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

    override func viewDidLoad() {
        super.viewDidLoad()

        let placeholders = ["Yellow Elephants", "Orange Koalas"]
        let images = [#imageLiteral(resourceName: "elephant"), #imageLiteral(resourceName: "koala")]

        let randomIndex = Int(arc4random_uniform(UInt32(placeholders.count)))
        self.nameTextField.text = placeholders[randomIndex]
        self.logoButton.setImage(images[randomIndex], for: .normal)
        if let selectedColor = self.colorCollectionView.cellForItem(at: IndexPath(index: randomIndex))?.backgroundColor {
            self.selectedColor = selectedColor
        }

        self.logoButton.layer.cornerRadius = 5.0
    }
    
    @IBAction func validateForm() {
        defer {
            self.navigationController?.popViewController(animated: true)
        }

        guard let text = self.nameTextField.text, let selectedImage = logoButton.image(for: .normal) else {
            return
        }

        let team = Team(name: text, color: self.selectedColor, image: selectedImage)
        Team.teams.append(team)

        self.addTeamAction?(team)
        if let playersNavigationViewController = self.tabBarController?.viewControllers?.first, let playersTableViewController = playersNavigationViewController.childViewControllers.first(where: { $0 is PlayersTableViewController }) as? PlayersTableViewController {
            playersTableViewController.forceReload = true
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
        let tintedLogoImage = self.logoButton.imageView?.image?.tint(with: self.selectedColor)
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
