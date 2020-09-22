//
//  ProfileViewCell.swift
//  Blink
//
//  Created by Brian Foley on 9/21/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

class ProfileViewCell: BaseCell {

    static var reuseId = "profileViewId"
    
    override func setupViews() {
        super.setupViews()
        setupView()
    }
    
    func setupView() {
        backgroundColor = .green
    }

}
