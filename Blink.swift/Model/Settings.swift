//
//  Settings.swift
//  Blink
//
//  Created by Brian Foley on 9/21/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import Foundation

struct Settings {
    
    var genderId: String?
    
    init(dictionary: [String: Any]) {
        self.genderId = dictionary["genderId"] as? String
    }
}
