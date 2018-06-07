//
//  TeamLogoCollectionViewController.swift
//  MixTeam
//
//  Created by Renaud JENNY on 19/07/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import UIKit

class TeamLogoCollectionViewController: UICollectionViewController {
    var selectedImage: UIImage? = nil
    var images: [UIImage?] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.images = [#imageLiteral(resourceName: "elephant"), #imageLiteral(resourceName: "koala"), #imageLiteral(resourceName: "panda"), #imageLiteral(resourceName: "octopus"), #imageLiteral(resourceName: "lion")]
    }
}

// MARK: - Collection View

extension TeamLogoCollectionViewController {
    static let cellIdentifier = "TeamLogoCollectionViewControllerCellIdentifier"

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TeamLogoCollectionViewController.cellIdentifier, for: indexPath) as? LogoCollectionViewCell else {
            fatalError("Cannot retrieve cell as LogoCollectionViewCell")
        }

        let image = self.images[indexPath.row]
        cell.logoImageView.image = image

        if self.selectedImage == self.images[indexPath.row] {
            cell.layer.borderWidth = 1.0
            cell.layer.borderColor = UIColor.black.cgColor
        }

        cell.isAccessibilityElement = true
        cell.accessibilityLabel = image?.appImage.rawValue

        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        self.selectedImage = self.imageForIndexPath(indexPath: indexPath)

        self.performSegue(withIdentifier: EditTeamViewController.fromLogoColletionSegueIdentifier, sender: nil)

        return true
    }

    func imageForIndexPath(indexPath: IndexPath) -> UIImage? {
        let item = self.collectionView?.cellForItem(at: indexPath) as? LogoCollectionViewCell
        return item?.logoImageView.image
    }
}
