//
//  ShoppingListTableViewCell.swift
//  Shopping List
//
//  Created by Pavel Moroz on 18.04.2020.
//  Copyright © 2020 Pavel Moroz. All rights reserved.
//

import UIKit

class ShoppingListTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var buyLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func set(list: List) {
        self.nameLabel.text = list.name
        if list.isBuy {
            self.buyLabel.text = "В Корзине"
            self.buyLabel.textColor = .systemGreen
        } else {
            self.buyLabel.text = "Нужно купить"
            self.buyLabel.textColor = .systemRed
        }
        let emodji = Emodji()
        let emodjiImage = emodji.setupName(list.name ?? "")
        self.imageLabel.text = emodjiImage
    }

}
