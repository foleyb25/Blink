//
//  Extension+CamGestureRecognizers.swift
//  Blink2
//
//  Created by Brian Foley on 5/22/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//
//  Extension of CameraViewController to handle all gesture Recognizers

import UIKit
import AVFoundation

extension MultiCamSession: UIGestureRecognizerDelegate {
    
    /**
     Adds gesture recognizers pertaining to the Camera View Controller
    
     ## Notes
      Gestures are stored as global variables because they may need to be toggled on/off like the flip camera functionality needs to be toggled off when in preview mode.
    
     - Warning: None
     - Parameter None
     - Returns: None
     
     ## Called in
     - CameraViewController.swift
    */
    func addCameraGestureRecognizers() {
        ///pinch to zoom
        guard let view = multiCamDelegate?.getView() else {return}
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoomGesture(pinch:)))
        view.addGestureRecognizer(pinchGesture)
        
        /// tap to focus
        let focusTapGesture = UITapGestureRecognizer(target: self, action: #selector(focusAndExposeTap(_:)))
        focusTapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(focusTapGesture)
        
        /// swipe up and down while recording to zoom
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(recordZoomGesture(pan:)))

        /// assign gestures to global variables so they can be toggled on/off
        self.pinchGesture = pinchGesture
        self.focusTapGesture = focusTapGesture
        self.recordPanGesture = panGesture
    }
    
    /**
     Handles pinch to zoom functionality of the camera
    
     ## Notes
     Enables the user to zoom in and out while the camera is open. Whenever the zoom factor of the IOS is manipulated, the capture device (front or back camera(s)) must be locked for configuration. The beginning zoom scale is saved as a global variable and is referenced everytime the zoomGesture is initiated. The cameras zoomfactor is set to the zoomScale which is calculated as follows:
     
     min ( max(beginZoomScale * pinch.scale , 1.0 ) , maximum zoom factor)
     
     Whenever the LHS exceeds the max zoom scale on the RHS of the min() function, the zoomScale variable will always be set to the maximum since the maximum zoom factor on the RHS would be the minimum: the LHS > RHS so return RHS. As for the inner max() function, 1.0 will be returned or begin zoomScale * pinch.scale. pinch.scale returns a value greater than 1 if pinch to zoom and a value less than 1 but greater than 0 if pinch to zoom out. if zoomScale is less than 1.0,  1.0 will always be returned. This makes it so the zoomScale will not be less than 1.0.
    
     - Warning: None
     - Parameter UIPinchGestureRecognizer
     - Returns: None
    */
    @objc func zoomGesture(pinch: UIPinchGestureRecognizer) {
        guard let captureDevice = currentDeviceInput?.device else { return }
        if pinch.state == .changed {
            do {
                try captureDevice.lockForConfiguration()
                  defer { captureDevice.unlockForConfiguration() }
                
                zoomScale = min(max(beginZoomScale * pinch.scale, 1.0),  captureDevice.activeFormat.videoMaxZoomFactor)
                captureDevice.videoZoomFactor = zoomScale
            } catch {
                print("Error locking configuration")
            }
        }
        if pinch.state == .ended {
            beginZoomScale = zoomScale
        }
    }
    
    /**
     Enables the user to control zoom with an upswipe or downswipe while recording
    
     ## Notes
     This is toggled on when recording and toggled off when not recording. See zoomGesture above to see the handling of the min/max functions. This works the same way with a slight difference because a pan gesture uses translation difference, as opposed to pinch scale, and is only concerned with the y-axis
    
     - Warning: None
     - Parameter UIPanGestureRecognizer
     - Returns: None
    */
    @objc func recordZoomGesture(pan: UIPanGestureRecognizer) {

        let currentTranslation    = pan.translation(in: multiCamDelegate?.getView()).y
        let translationDifference = currentTranslation - beginZoomScale

        do {
            let captureDevice = self.currentDeviceInput?.device
            
            try captureDevice?.lockForConfiguration()
            defer { captureDevice?.unlockForConfiguration() }

            zoomScale = min(max(beginZoomScale - (translationDifference * 0.0125), 1.0),  captureDevice!.activeFormat.videoMaxZoomFactor)

            captureDevice?.videoZoomFactor = zoomScale
            

        } catch {
            print("Error locking configuration")
        }

        if pan.state == .ended || pan.state == .failed || pan.state == .cancelled {
            beginZoomScale = zoomScale
        }
    }
    
    /**
     Focuses camera on specified point that is tapped
    
     ## Notes
     focuses on tapped point using autoExposure
    
     - Warning: None
     - Parameter None
     - Returns: None
     
    */
    @objc func focusAndExposeTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let devicePoint = multiCamDelegate?.getFrontViewLayer()?.captureDevicePointConverted(fromLayerPoint: gestureRecognizer.location(in: gestureRecognizer.view))
        dualVideoSessionOutputQueue.async {
            self.focus(with: .autoFocus, exposureMode: .autoExpose, at: devicePoint!, monitorSubjectAreaChange: true)
        }
        
//        let devicePoint = multiCamDelegate?.getBackViewLayer()?.captureDevicePointConverted(fromLayerPoint: gestureRecognizer.location(in: gestureRecognizer.view))
//        focus(with: .autoFocus, exposureMode: .autoExpose, at: devicePoint!, monitorSubjectAreaChange: true)
    }
    
    /**
     Helper function for focusAndExposeTap
    
     ## Notes
     If a user updates their information, the current user's data in this class is updated. If not, this creates conflicts when attempting to display data or access parts of the app. This method updates the current users information specifically if the user has registered for the Gene Pool and fixes the problem.
    
     - Warning: None
     - Parameters:
        - focusMode: Enum Int
        - exposureMode: Enum Int
        - devicePoint: CGFloat of point tapped on screen
        - monitorSubectAreaChange: Boolean to indicate whether subject area should be monitored

     - Returns: None
     
    */
    private func focus(with focusMode: AVCaptureDevice.FocusMode,
        exposureMode: AVCaptureDevice.ExposureMode,
        at devicePoint: CGPoint,
        monitorSubjectAreaChange: Bool) {
        
        guard let device = self.currentDeviceInput?.device else { return }
            do {
                try device.lockForConfiguration()
                
                /*
                 Set Focus and Exposure Mode() to apply the new point of interest.
                 */
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                    device.focusPointOfInterest = devicePoint
                    device.focusMode = focusMode
                }
                
                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                    device.exposurePointOfInterest = devicePoint
                    device.exposureMode = exposureMode
                }
                
                device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
            } catch {
                print("Could not lock device for configuration: \(error)")
            }
    }
    
    /**
     Focus's camera whenever the capture device detects a change in video
    
     ## Notes
     An observer is set on the capture device for this. Set when initially setting up camera and whenever the flips.
    
     - Warning: None
     - Parameters:
        - notification: NSNotification an observer assigned to the capture device
     - Returns: None
     
    */
    @objc func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        focus(with: .continuousAutoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: false)
    }
    
}

extension CameraViewController {
    
    func addUIGestureRecognizers() {
        ///double tap to switch camera
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(flipCameraPressed))
        tapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(tapGesture)
        
        /// swipe right to present side menu bar
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(friendsButtonPressed))
        swipeRightGesture.direction = .right
        self.view.addGestureRecognizer(swipeRightGesture)
        
        multiCamSession?.tapGesture = tapGesture
        multiCamSession?.swipeRightGesture = swipeRightGesture
    }
}
