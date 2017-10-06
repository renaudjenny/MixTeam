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

    var team = AddTeamViewController.randomTeam()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.nameTextField.text = self.team.name
        self.logoButton.setImage(self.team.image?.tint(with: self.team.color), for: .normal)
        self.logoButton.accessibilityIdentifier = self.team.image?.appImage.rawValue
        self.logoButton.backgroundColor = self.team.color.withAlphaComponent(0.10)

        self.logoButton.layer.cornerRadius = 5.0
    }

    class func randomTeam() -> Team {
        let titlesForImages = [("Elephants", #imageLiteral(resourceName: "elephant")), ("Koalas", #imageLiteral(resourceName: "koala")), ("Pandas", #imageLiteral(resourceName: "panda")), ("Octopus", #imageLiteral(resourceName: "octopus"))]
        let titlesForColors = UXColor.allColors().map { (color) -> (String, UIColor) in
            return (UXColor.toString(color: color).capitalized, color)
        }

        let randomIndexForImage = Int(arc4random_uniform(UInt32(titlesForImages.count)))
        let randomIndexForColor = Int(arc4random_uniform(UInt32(titlesForColors.count)))

        let (imageTitle, image) = titlesForImages[randomIndexForImage]
        let (colorTitle, color) = titlesForColors[randomIndexForColor]

        let teamTitle = colorTitle + " " + imageTitle

        return Team(name: teamTitle, color: color, image: image)
    }

    @IBAction func validateForm() {
        guard let name = self.nameTextField.text, !name.isEmpty else {
            let alertController = UIAlertController(title: "Hhmm!", message: "A team is much better with a name!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alertController, animated: true)
            return
        }

        self.team.name = name
        self.team.save()

        self.performSegue(withIdentifier: TeamsTableViewController.fromAddTeamUnwindSegueIdentifier, sender: nil)
    }
}

// MARK: - Navigation

extension AddTeamViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let teamLogoViewController = segue.destination as? TeamLogoCollectionViewController {
            teamLogoViewController.selectedImage = self.team.image
        }
    }

    @IBAction func teamLogoUnwind(segue: UIStoryboardSegue) {
        if let teamLogoCollectionViewController = segue.source as? TeamLogoCollectionViewController {
            self.team.image = teamLogoCollectionViewController.selectedImage
            let tintedImage = self.team.image?.tint(with: self.team.color)

            self.logoButton.setImage(tintedImage, for: .normal)
            self.logoButton.accessibilityIdentifier = self.team.image?.appImage.rawValue
        }
    }
}

private let kAddTeamViewControllerCollectionViewCellIdentifier: String = "addTeamViewControllerCollectionViewCellIdentifier"

extension AddTeamViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UXColor.allColors().count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kAddTeamViewControllerCollectionViewCellIdentifier, for: indexPath)

        let colorView = UIView()
        colorView.translatesAutoresizingMaskIntoConstraints = false
        let color = UXColor.allColors()[indexPath.row]
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
        self.team.color = UXColor.allColors()[indexPath.row]
        let tintedLogoImage = self.team.image?.tint(with: self.team.color)
        self.logoButton.setImage(tintedLogoImage, for: .normal)
        self.logoButton.backgroundColor = self.team.color.withAlphaComponent(0.10)
    }
}

extension AddTeamViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nameTextField.resignFirstResponder()
        return true
    }
}
