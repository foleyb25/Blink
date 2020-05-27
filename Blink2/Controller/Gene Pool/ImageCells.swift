//
//  ImageCells.swift
//  Blink2
//
//  Created by Brian Foley on 5/26/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

class ImageCells: BaseCell {
    
    override func setupViews() {
        super.setupViews()
        backgroundColor = UIColor.blue
        layer.cornerRadius = 20
        layer.masksToBounds = true
    }
}
