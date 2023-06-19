//
//  CategoryCell.swift
//  Shopping List
//
//  Created by Admin on 30/11/2022.
//  Copyright © 2022 Pavel Moroz. All rights reserved.
//

import UIKit

protocol SelfConfiguringCell {
    static var reuseId: String { get }
    func configure<U: Hashable>(with value: U)
}

class CategoryCell: UICollectionViewCell, SelfConfiguringCell {

    let categoryImageView = UIImageView()
    let categoryName = UILabel()
    let containerView = UIView()

    static var reuseId: String = "UserCell"

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupConstraints()

        self.layer.cornerRadius = 4
        self.layer.shadowColor = #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 1)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.layer.cornerRadius = 4
        self.containerView.clipsToBounds = true
        
    }

    func configure<U>(with value: U) where U : Hashable {
        guard let category: CategoryItem = value as? CategoryItem else { return }
        categoryName.text = category.nameCategory
        categoryName.textAlignment = .center
        
      //  let orderCategory = category.id - 2
        
//        if orderCategory  < 4 {
//            categoryImageView.image = UIImage(named: "shopping\(orderCategory)@3x")
//        } else {
//            categoryImageView.image = UIImage(named: "shopping3@3x")
//        }
        
        categoryImageView.image = UIImage(named: "welcomeIcon2")
        
    }

    private func setupConstraints() {
        categoryImageView.translatesAutoresizingMaskIntoConstraints = false
        categoryName.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false

        categoryImageView.backgroundColor = .clear
        
        
        addSubview(containerView)
        containerView.addSubview(categoryImageView)
        containerView.addSubview(categoryName)
        
        categoryName.backgroundColor = UIColor(white: 0.95, alpha: 0.3)
        

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            categoryImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            categoryImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            categoryImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            categoryImageView.heightAnchor.constraint(equalTo: containerView.widthAnchor)
        ])

        NSLayoutConstraint.activate([
            categoryName.topAnchor.constraint(equalTo: categoryImageView.bottomAnchor),
            categoryName.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            categoryName.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            categoryName.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
