//
//  User.swift
//  Blink
//
//  Created by Brian Foley on 6/18/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

class User: NSObject {
    var firstName: String?
    var lastName: String?
    var userId: String?
    var username: String?
    var profileURL: String?
    var genderId: String?
    var friends: [String]?
    
    init(dictionary: [String: Any]) {
        self.firstName = dictionary["firstname"] as? String
        self.lastName = dictionary["lastname"] as? String
        self.userId = dictionary["userId"] as? String
        self.username = dictionary["username"] as? String
        self.profileURL = dictionary["profileImage"] as? String
        self.genderId = dictionary["userid"] as? String
        self.friends = dictionary["friends"] as? String
    }
}
