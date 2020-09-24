//
//  PreviewMediaView+buttons.swift
//  Blink
//
//  Created by Brian Foley on 9/22/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

extension PreviewMediaView {
    
    /**
     Removes photo or video from media preview layer
    
     ## Notes
      Cancel button is displayed only in preview mode. Setting values to nil makes preview layer(s) transparent
    
     - Warning: None
     - Parameter None
     - Returns: None
     
     ## Called in
     - CameraViewController.swift
    */
    @objc func cancelPressed() {
        guard let owningVC = getOwningViewController() as? CameraViewController else { return }
        owningVC.isInPreviewMode = false
        owningVC.navigationController?.navigationBar.isHidden = owningVC.isInPreviewMode
        self.imagePreview.image = nil
        self.playerLayer.player = nil
        self.removeFromSuperview()
    }
    
    /**
     Sends media content to sendMessageController and presents message controller
     
    ## Notes
     Displays only in preview mode
     
     - Warning: None
     - Parameter None
     - Returns: None
     
     ## Called in
     - CameraViewController.swift
    */
    @objc func sendPressed() {
        guard let owningVC = getOwningViewController() as? CameraViewController else { return }
        
        let sendMessageController = SendMessageController()
        sendMessageController.image = self.image
        sendMessageController.camController = owningVC
        owningVC.navigationController?.pushViewController(sendMessageController, animated: true)
        
    }
}
