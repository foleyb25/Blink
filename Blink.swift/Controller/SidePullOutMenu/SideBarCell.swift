//
//  SideBarCell.swift
//  Blink2
//
//  Created by Brian Foley on 5/21/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

class SideBarCell: BaseCell {
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.33) {
                self.backgroundColor = self.isHighlighted ? UIColor.darkGray : UIColor.white
            }
        }
    }
    
    var cellItem: CellItem? {
        didSet {
            nameLabel.text = cellItem?.name
            if let imageName = cellItem?.imageName {
                
                iconImageView.image = UIImage(systemName: imageName)
            }
        }
    }
    
    let nameLabel: UILabel = {
        let labelItem = UILabel()
        return labelItem
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(nameLabel)
        addSubview(iconImageView)
        setupConstraints()
    }
    
    func setupConstraints() {
        
        addConstraintsWithFormat("H:|-8-[v0(30)]-8-[v1]|", views: iconImageView, nameLabel)

        addConstraintsWithFormat("V:|[v0]|", views: nameLabel)
        
        addConstraintsWithFormat("V:[v0(30)]", views: iconImageView)
        
        addConstraint(NSLayoutConstraint(item: iconImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
}



class CellItem: NSObject {
    let name: String
    let imageName: String
    let controller: UIViewController
    
    init(name: String, imageName: String, controller: UIViewController) {
        self.name = name
        self.imageName = imageName
        self.controller = controller
    }
}
