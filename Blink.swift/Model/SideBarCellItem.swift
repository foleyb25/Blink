//
//  SideBarCellItem.swift
//  Blink
//
//  Created by Brian Foley on 9/2/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

class SideBarCellItem: NSObject {
    let name: String
    let imageName: String
    let controller: UIViewController
    
    init(name: String, imageName: String, controller: UIViewController) {
        self.name = name
        self.imageName = imageName
        self.controller = controller
    }
}
