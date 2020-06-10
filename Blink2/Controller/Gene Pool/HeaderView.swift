//
//  HeaderView.swift
//  Blink2
//
//  Created by Brian Foley on 6/10/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

class HeaderView: UICollectionReusableView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .red
    }
    
    required init?(coder: NSCoder) {
        fatalError("Fatal Error")
    }
}
