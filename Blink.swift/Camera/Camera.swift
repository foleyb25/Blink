//
//  Camera.swift
//  Blink
//
//  Created by Brian Foley on 9/24/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import AVFoundation

class Camera: AVCaptureSession {
    
    override init() {
        super.init()
        self.startRunning()
    }
}
