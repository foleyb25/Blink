//
//  Extension+CamGestureRecognizers.swift
//  Blink2
//
//  Created by Brian Foley on 5/22/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit
import AVFoundation

extension CameraViewController: UIGestureRecognizerDelegate {
    internal func addGestureRecognizers() {
        
        //pinch to zoom
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoomGesture(pinch:)))
        self.view.addGestureRecognizer(pinchGesture)
        
        //double tap to switch camera
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(flipCameraPressed))
        tapGesture.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(tapGesture)
        
        let focusTapGesture = UITapGestureRecognizer(target: self, action: #selector(focusAndExposeTap(_:)))
        focusTapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(focusTapGesture)
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(friendsButtonPressed))
        swipeRightGesture.direction = .right
        self.view.addGestureRecognizer(swipeRightGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(recordZoomGesture(pan:)))
        
        self.pinchGesture = pinchGesture
        self.tapGesture = tapGesture
        self.focusTapGesture = focusTapGesture
        self.swipeRightGesture = swipeRightGesture
        self.recordPanGesture = panGesture
    }
    
    
    
    @objc internal func zoomGesture(pinch: UIPinchGestureRecognizer) {
        let captureDevice = self.videoDeviceInput.device
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
    
    @objc internal func recordZoomGesture(pan: UIPanGestureRecognizer) {

        let currentTranslation    = pan.translation(in: view).y
        let translationDifference = currentTranslation - beginZoomScale

        do {
            let captureDevice = self.videoDeviceInput.device
            
            try captureDevice.lockForConfiguration()
            defer { captureDevice.unlockForConfiguration() }

            print(translationDifference / 10)
            zoomScale = min(max(beginZoomScale - (translationDifference * 0.0125), 1.0),  captureDevice.activeFormat.videoMaxZoomFactor)

            captureDevice.videoZoomFactor = zoomScale
            

        } catch {
            print("Error locking configuration")
        }

        if pan.state == .ended || pan.state == .failed || pan.state == .cancelled {
            beginZoomScale = zoomScale
        }
    }
    
    
    
    @objc internal func focusAndExposeTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let devicePoint = previewLayer.captureDevicePointConverted(fromLayerPoint: gestureRecognizer.location(in: gestureRecognizer.view))
        focus(with: .autoFocus, exposureMode: .autoExpose, at: devicePoint, monitorSubjectAreaChange: true)
    }
    
    internal func focus(with focusMode: AVCaptureDevice.FocusMode,
        exposureMode: AVCaptureDevice.ExposureMode,
        at devicePoint: CGPoint,
        monitorSubjectAreaChange: Bool) {
        
        sessionQueue.async {
            let device = self.videoDeviceInput.device
            do {
                try device.lockForConfiguration()
                
                /*
                 Setting (focus/exposure)PointOfInterest alone does not initiate a (focus/exposure) operation.
                 Call set(Focus/Exposure)Mode() to apply the new point of interest.
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
    }
    
    @objc func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        focus(with: .continuousAutoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: false)
    }
}
