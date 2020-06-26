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
    var username: String?
    var profileImageURL: String?
    var genderId: String?
    var friends: [String]?
    var didRegisterGP: Bool?
    
    init(dictionary: [String: Any]) {
        self.firstName = dictionary["firstname"] as? String
        self.lastName = dictionary["lastname"] as? String
        self.username = dictionary["username"] as? String
        self.profileImageURL = dictionary["profileimageurl"] as? String
        self.genderId = dictionary["genderid"] as? String
        self.friends = dictionary["friends"] as? [String]
        self.didRegisterGP = dictionary["didregister"] as? Bool
    }
}
