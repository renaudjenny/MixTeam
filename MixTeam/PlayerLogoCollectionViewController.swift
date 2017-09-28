//
//  PlayerLogoCollectionViewController.swift
//  MixTeam
//
//  Created by Renaud JENNY on 08/05/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import UIKit

class PlayerLogoCollectionViewController: UICollectionViewController {
    enum Mode {
        case add
        case edit
    }

    var selectedImage: UIImage? = nil
    var images: [UIImage?] = []

    var mode = Mode.add

    override func viewDidLoad() {
        super.viewDidLoad()

        self.images = [#imageLiteral(resourceName: "harry-pottar"), #imageLiteral(resourceName: "dark-vadir"), #imageLiteral(resourceName: "amalie-poulain"), #imageLiteral(resourceName: "lara-craft")]
    }
}

// MARK: - Collection View

extension PlayerLogoCollectionViewController {
    static let cellIdentifier = "PlayerLogoCollectionViewControllerCellIdentifier"

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlayerLogoCollectionViewController.cellIdentifier, for: indexPath) as? LogoCollectionViewCell else {
            fatalError("Cannot continue without cell as LogoCollectionViewCell")
        }

        cell.logoImageView.image = self.images[indexPath.row]

        if self.selectedImage == self.images[indexPath.row] {
            cell.layer.borderWidth = 1.0
            cell.layer.borderColor = UIColor.black.cgColor
        }

        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        self.selectedImage = self.imageForIndexPath(indexPath: indexPath)

        switch self.mode {
        case .add:
            self.performSegue(withIdentifier: AddPlayerViewController.fromLogoCollectionUnwindSegueIdentifier, sender: nil)
        case .edit:
            self.performSegue(withIdentifier: EditPlayerViewController.fromLogoCollectionUnwindSegueIdentifier, sender: nil)
        }

        return true
    }

    func imageForIndexPath(indexPath: IndexPath) -> UIImage? {
        let item = self.collectionView?.cellForItem(at: indexPath) as? LogoCollectionViewCell
        return item?.logoImageView.image
    }
}
