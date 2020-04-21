//
//  IconsTableViewCell.swift
//  Shopping List
//
//  Created by Pavel Moroz on 22.04.2020.
//  Copyright © 2020 Pavel Moroz. All rights reserved.
//

import UIKit

class IconsTableViewCell: UITableViewCell, UICollectionViewDataSource {


    override func awakeFromNib() {
           super.awakeFromNib()
           // Initialization code
       }


   // MARK: UICollectionViewDataSource
      func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

          return 3
      }

      func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "iconCell", for: indexPath) as! IconsCollectionViewCell
          cell.iconsImageCell.imageView?.image = UIImage(named: "shopping1")

          return cell
      }

}
