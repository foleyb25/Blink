//
//  SlideInPresentationManager.swift
//  Blink2
//
//  Created by Brian Foley on 5/20/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

class SlideInPresentationManager: NSObject {

    enum PresentationDirection {
      case left
      case top
      case right
      case bottom
    }
    
    var direction: PresentationDirection = .left
}

extension SlideInPresentationManager: UIViewControllerTransitioningDelegate {
    
}
