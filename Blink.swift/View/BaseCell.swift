//
//  BaseCell.swift
//  Blink
//
//  Created by Brian Foley on 8/31/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init has not been implemented")
    }
}
