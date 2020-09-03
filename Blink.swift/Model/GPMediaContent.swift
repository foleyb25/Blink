//
//  GPMediaContent.swift
//  Blink
//
//  Created by Brian Foley on 9/2/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

class GPMediaContent: NSObject {
    var username: String?
    var mediaURL: String?
    
    init(dictionary: [String: Any]) {
        username = dictionary["username"] as? String
        mediaURL = dictionary["mediaURL"] as? String
    }
}
