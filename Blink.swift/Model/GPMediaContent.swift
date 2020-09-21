//
//  GPMediaContent.swift
//  Blink
//
//  Created by Brian Foley on 9/2/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

class GPMediaContent: NSObject {
    var mediaThumbnailURL: String?
    var mediaURL: String?
    var creationDate: Date?
    var location: CGPoint?
    var caption: String?
    
    init(dictionary: [String: Any]) {
        mediaThumbnailURL = dictionary["thumbnailURL"] as? String
        mediaURL = dictionary["mediaURL"] as? String
        creationDate = dictionary["username"] as? Date
        location = dictionary["location"] as? CGPoint
        caption = dictionary["caption"] as? String
    }
}
