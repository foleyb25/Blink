//
//  CameraSideViewMenu.swift
//  Blink2
//
//  Created by Brian Foley on 5/20/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

class CameraViewPresentation: UIPresentationController {
    
    
    override var frameOfPresentedViewInContainerView: CGRect {
        
        
        let containerFrame = self.containerView!.frame
         return CGRect(x: 0, y: 0, width: containerFrame.width/1.5, height: containerFrame.height) //From the left
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
}
