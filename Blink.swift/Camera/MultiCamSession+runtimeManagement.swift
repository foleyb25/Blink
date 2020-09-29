//
//  CameraView+runtimeManagement.swift
//  Blink
//
//  Created by Brian Foley on 9/24/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//
import UIKit
import AVFoundation

extension MultiCamSession {
    
    // MARK: Runtime Error Management
    @objc func sessionRuntimeError(notification: NSNotification) {
        print("Session Runtime Error")
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        print("Capture session runtime error: \(error)")
        // If media services were reset, and the last start succeeded, restart the session.
        if error.code == .mediaServicesWereReset {
            dualVideoSessionOutputQueue.async {
                if self.isSessionRunning {
                    self.startRunning()
                    self.isSessionRunning = self.isRunning
                }
            }
        }
    }
    
    /// - Tag: HandleSystemPressure
    func setRecommendedFrameRateRangeForPressureState(systemPressureState: AVCaptureDevice.SystemPressureState) {
        /*
         The frame rates used here are only for demonstration purposes.
         Your frame rate throttling may be different depending on your app's camera configuration.
         */
        let pressureLevel = systemPressureState.level
        if pressureLevel == .serious || pressureLevel == .critical {
            if self.isRecording == false {
                do {
                    try backCaptureDevice!.lockForConfiguration()
                    print("WARNING: Reached elevated system pressure level: \(pressureLevel). Throttling frame rate.")
                    self.backCaptureDevice!.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 20)
                    self.backCaptureDevice!.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 15)
                    self.backCaptureDevice!.unlockForConfiguration()
                    
                    try frontCaptureDevice!.lockForConfiguration()
                    self.frontCaptureDevice!.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 20)
                    self.frontCaptureDevice!.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 15)
                    self.frontCaptureDevice!.unlockForConfiguration()
                } catch {
                    print("Could not lock device for configuration: \(error)")
                }
            }
        } else if pressureLevel == .shutdown {
            print("Session stopped running due to shutdown system pressure level.")
        }
    }
    
    @objc func sessionWasInterrupted(notification: NSNotification) {
        /*
         In some scenarios you want to enable the user to resume the session.
         For example, if music playback is initiated from Control Center while
         using AVCam, then the user can let AVCam resume
         the session running, which will stop music playback. Note that stopping
         music playback in Control Center will not automatically resume the session.
         Also note that it's not always possible to resume, see `resumeInterruptedSession(_:)`.
         */
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
            let reasonIntegerValue = userInfoValue.integerValue,
            let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
            print("Capture session was interrupted with reason \(reason)")
            
            
            if reason == .audioDeviceInUseByAnotherClient || reason == .videoDeviceInUseByAnotherClient {
                print("Video or audio device is in use by another client")
            } else if reason == .videoDeviceNotAvailableWithMultipleForegroundApps {
                print("Video device not available with multiple foreground apps")
            } else if reason == .videoDeviceNotAvailableDueToSystemPressure {
                print("Session stopped running due to shutdown system pressure level.")
            } else if reason == .videoDeviceNotAvailableInBackground {
                print("video device not available in background")
            }
        }
    }
    
    @objc func sessionInterruptionEnded(notification: NSNotification) {
        print("Capture session interruption ended")
    }
}
