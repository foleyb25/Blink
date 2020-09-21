//
//  User.swift
//  Blink
//
//  Created by Brian Foley on 6/18/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

struct User {
    
    let uid: String?
    let firstName: String?
    let lastName: String?
    let username: String?
    let profileImageURL: String?
    
    
    init(dictionary: [String: Any], uid: String?) {
        self.uid = uid
        self.firstName = dictionary["firstname"] as? String
        self.lastName = dictionary["lastname"] as? String
        self.username = dictionary["username"] as? String
        self.profileImageURL = dictionary["profileimageurl"] as? String
    }
     
}
