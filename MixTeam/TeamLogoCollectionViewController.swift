//
//  TeamLogoCollectionViewController.swift
//  MixTeam
//
//  Created by Renaud JENNY on 19/07/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import UIKit

private let kTeamLogoCollectionViewIdentifier = "teamLogoCollectionViewIdentifier"

class TeamLogoCollectionViewController: UICollectionViewController {
    var selectedImage: UIImage? = nil
    var images: [UIImage?] = []
    var onSelectedImageAction: (UIImage?) -> Void = { (image) in }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kTeamLogoCollectionViewIdentifier)

        self.images = [#imageLiteral(resourceName: "elephant"), #imageLiteral(resourceName: "koala"), #imageLiteral(resourceName: "panda")]
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kTeamLogoCollectionViewIdentifier, for: indexPath)

        let image = self.images[indexPath.row]
        let imageView = UIImageView(image: image)
        imageView.contentMode = .center
        cell.addSubview(imageView)
        cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil, views: ["imageView": imageView]))
        cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", options: [], metrics: nil, views: ["imageView": imageView]))

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
        self.onSelectedImageAction(self.selectedImage)

        self.dismiss(animated: true, completion: nil)

        return true
    }

    func imageForIndexPath(indexPath: IndexPath) -> UIImage? {
        let item = self.collectionView?.cellForItem(at: indexPath)
        let imageView = item?.subviews.first(where: { (subview) -> Bool in
            return subview is UIImageView
        }) as? UIImageView
        
        return imageView?.image
    }
}
