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
    @IBOutlet weak var imageProduct: UIImageView!

    @IBOutlet weak var buyLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!

    private let defaults = UserDefaults.standard
    private var costAccounting: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func set(list: List) {

        costAccounting = defaults.bool(forKey: "costAccounting")
        costLabel.isHidden = !costAccounting

        self.nameLabel.text = list.name
        let currency = defaults.string(forKey: "currency") ?? NSLocalizedString("CurrentCurrency", comment: "")
        self.costLabel.text = "\(list.cost) \(currency)"
        if list.isBuy {
            self.buyLabel.text = NSLocalizedString("InTheBasket", comment: "")
            self.buyLabel.textColor = .systemGreen
        } else {
            self.buyLabel.text = NSLocalizedString("NeedToBuy", comment: "")
            self.buyLabel.textColor = .systemRed
        }
        let emodji = Emodji()
        let emodjiImage = emodji.setupName(list.name ?? "default")
        self.imageProduct.image = UIImage(named: "\(emodjiImage.lowercased())")
    }
}
