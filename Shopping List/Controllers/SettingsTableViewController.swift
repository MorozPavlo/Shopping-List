//
//  SettingsTableViewController.swift
//  Shopping List
//
//  Created by Pavel Moroz on 22.04.2020.
//  Copyright © 2020 Pavel Moroz. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!

    var imageSetNames: [String] = ["shopping0@3x.png","shopping1@3x.png","shopping2@3x.png","shopping3@3x.png"]
    var imageNames: [String] = ["Основная","Синий Бриз","Необычность","Простота"]

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
    }


    // MARK: UICollectionViewDataSource
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

           return 4
       }

       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "iconCell", for: indexPath) as! IconsCollectionViewCell

        cell.iconsButtonImage.setTitle("", for: .normal)
        let image = UIImage(named: imageSetNames[indexPath.row], in: Bundle.main, compatibleWith: nil)
        cell.iconsButtonImage.setBackgroundImage(image, for: .normal)
        cell.iconsName.text = imageNames[indexPath.row]
        cell.iconsButtonImage.layer.cornerRadius = 16
        cell.iconsButtonImage.clipsToBounds = true

           return cell
       }

}
