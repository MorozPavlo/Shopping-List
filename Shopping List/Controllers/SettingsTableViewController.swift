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
    let appIconServise = AppIconServise()

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


        let image = UIImage(named: imageSetNames[indexPath.row], in: Bundle.main, compatibleWith: nil)
        cell.iconImage.image = image
        cell.iconsName.text = imageNames[indexPath.row]
        cell.iconImage.layer.cornerRadius = 16
        cell.iconImage.clipsToBounds = true

           return cell
       }

        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

            switch indexPath.row {
            case 0:
                appIconServise.changeAppIcon(to: .primaryAppIcon)
                case 1:
                    appIconServise.changeAppIcon(to: .shopping1)
                case 2:
                    appIconServise.changeAppIcon(to: .shopping2)
                case 3:
                    appIconServise.changeAppIcon(to: .shopping3)
            default:
                appIconServise.changeAppIcon(to: .primaryAppIcon)
            }

        }

}
