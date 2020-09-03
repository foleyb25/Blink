//
//  Extensions.swift
//  Blink
//
//  Created by Brian Foley on 6/16/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//
//  The Extensions.swift file is used to store all non class specific extensions. All Global extensions.

import UIKit


extension UIColor {
    /**
    Used to get a UIColor with values of 0-255 for red green blue instead of values between 0-1.
    
    ## Notes
     Alpha is a value between 0-1. A 0-255 RGB selector is  essential when trying to find a precise color pulled from an application like photoshop or a color selector.
    
     - Warning: None
     - Parameter CGFloat
     - Returns: UIColor
    */
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor{
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }

}


extension UIView {
    
    /**
    Shorthand method for adding constraints to multiple views.

    ## Notes
     Follows the standard visual format. for example "V:|[item]| - [item2]..." This function allows to add constraints to multiple views at once. The view names and attributes are parsed from the format String parameter, added as a key to a dictionary, and prepped for the constraints(withvisualformat: ... function)
     
     See more on visual formatting here  https://www.hackingwithswift.com/read/6/3/auto-layout-in-code-addconstraints-with-visual-format-language

     - Warning: None
     - Parameter String, UIVIew
     - Returns: UIColor
    */
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
}
