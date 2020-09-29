//
//  Camera.swift
//  Blink
//
//  Created by Brian Foley on 9/24/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//
//  1)Initialize Multicam session eg. var multicamsession = MultiCamSession()
//  2) call configureCamerasInputOutput()
//  3) call multicamsession.start()

import AVFoundation
import UIKit

protocol MultiCamSessionDelegate: AnyObject {
    func getFrontViewLayer() -> AVCaptureVideoPreviewLayer?
    func getBackViewLayer() -> AVCaptureVideoPreviewLayer?
    func getView() -> UIView?
    func checkSetupResult()
    func togglePreviewMode(url: URL?, image: UIImage?)
    func toggleButtons(isHidden: Bool)
}

class MultiCamSession: AVCaptureMultiCamSession {
    
    enum _CaptureState {
        case idle
        case start
        case running
        case finished
    }
    
    var _captureState: _CaptureState = .idle
    
    enum CameraSelection: String {
        // Camera on the back of the device
        case rear = "rear"
        // Camera on the front of the device
        case front = "front"
    }
    
    enum Flashmode: String {
        case auto = "auto"
        case on = "on"
        case off = "off"
    }
    
    enum SessionSetupResult {
        case success
        case camNotAuthorized
        case configurationFailed
    }
    
    var backgroundRecordingID: UIBackgroundTaskIdentifier?
    
    private var setupResult: SessionSetupResult = .success
    
    var audioAuthorized = true
    
    public var currentCamera = CameraSelection.rear
    public var flashMode = Flashmode.auto
    
    var isSessionRunning: Bool = false
    var isRecording: Bool = false
    var isCapturePhoto: Bool = false
    
    weak var multiCamDelegate: MultiCamSessionDelegate?
    
    var url: URL?
    
    var isInDualCameraMode: Bool = false
    
    var currentDeviceInput: AVCaptureDeviceInput?
    
    var backDeviceInput:AVCaptureDeviceInput?
    var backVideoDataOutput = AVCaptureVideoDataOutput()
    

    var backAudioDataOutput = AVCaptureAudioDataOutput()
    private var backCameraInputVideoPort: AVCaptureInput.Port?
    
    var frontDeviceInput:AVCaptureDeviceInput?
    var frontVideoDataOutput = AVCaptureVideoDataOutput()
    
    var frontCaptureDevice: AVCaptureDevice?
    
    var backCaptureDevice: AVCaptureDevice?
    
    
    var frontAudioDataOutput = AVCaptureAudioDataOutput()
    private var frontCameraInputVideoPort: AVCaptureInput.Port?
    
    //Queue for managing dual session
    var dualVideoSessionOutputQueue = DispatchQueue(label: "dualVideoQueue")
    
    //queue to handle CMBuffer for video and photo
    let videoSessionQueue = DispatchQueue(label: "video_capture_session_queue")
    
    var beginZoomScale = CGFloat(1.0)
    var zoomScale = CGFloat(1.0)
    var previousPanTranslation: CGFloat = 0.0
    public var maxZoomScale = CGFloat.greatestFiniteMagnitude
    var recordPanGesture: UIPanGestureRecognizer?
    var pinchGesture: UIPinchGestureRecognizer?
    var tapGesture: UITapGestureRecognizer?
    var focusTapGesture: UITapGestureRecognizer?
    var swipeRightGesture: UISwipeGestureRecognizer?
    
    //AVAssetWriter & Recording Variables
    var assetWriter: AVAssetWriter!
    var videoWriterInput: AVAssetWriterInput!
    var audioWriterInput: AVAssetWriterInput!
    var fileName = ""
    
    override init() {
        super.init()
        
        /*
         Check the video authorization status. Video access is required and audio
         access is optional. If the user denies audio access, AVCam won't
         record audio during movie recording.
         */
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera.
            break
        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant
             video access. Suspend the session queue to delay session
             setup until the access request has completed.
             */
             dualVideoSessionOutputQueue.suspend()
             AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                 if !granted {
                     self.setupResult = .camNotAuthorized
                 }
                 self.dualVideoSessionOutputQueue.resume()
             })
             /*
             Note that audio access will be implicitly requested when we
             create an AVCaptureDeviceInput for audio during session setup.
             */
        case .denied:
            print("denied")
            dualVideoSessionOutputQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .camNotAuthorized
                }
                self.dualVideoSessionOutputQueue.resume()
            })
        case .restricted:
            print("restricted")
            dualVideoSessionOutputQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .camNotAuthorized
                }
                self.dualVideoSessionOutputQueue.resume()
            })
        default:
            // The user has previously denied access.
            setupResult = .camNotAuthorized
        }
        
    }
    
    func getSetupResult() -> SessionSetupResult {
        return setupResult
    }
    
    func configureCamerasInputOutput() {
        guard AVCaptureMultiCamSession.isMultiCamSupported else {
            print("MultiCam not supported")
            return
        }
        
        dualVideoSessionOutputQueue.async {
            
            self.beginConfiguration()
            self.setupFrontCamera()
            self.setupBackCamera()
            self.commitConfiguration()
            self.multiCamDelegate?.checkSetupResult()
        }
    }
    
    func setupFrontCamera() {
        guard let frontCamera = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .front) else {return}
        frontCaptureDevice = frontCamera
        // set up front camera
        do {
            let frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            frontDeviceInput = frontCameraInput
            if canAddInput(frontCameraInput) {
                addInputWithNoConnections(frontCameraInput)
            } else {
                print("could not add front camera input")
            }
            
            guard let frontCameraPort = frontCameraInput.ports(for: .video, sourceDeviceType: frontCamera.deviceType, sourceDevicePosition: frontCamera.position).first else {return}
            
            if canAddOutput(frontVideoDataOutput) {
                addOutputWithNoConnections(frontVideoDataOutput)
            } else {
                print("Coud not add back cam video data output")
            }
            
            frontVideoDataOutput.videoSettings = [:]
            frontVideoDataOutput.setSampleBufferDelegate(self, queue: videoSessionQueue)
            
            let frontOutputConnection = AVCaptureConnection(inputPorts: [frontCameraPort], output: frontVideoDataOutput)
            
            if canAddConnection(frontOutputConnection) {
                addConnection(frontOutputConnection)
            } else {
                print("Could not add back output connection")
            }
            frontOutputConnection.videoOrientation = .portrait
            guard let frontViewLayer = multiCamDelegate?.getFrontViewLayer() else {return}
            let frontConnection = AVCaptureConnection(inputPort: frontCameraPort, videoPreviewLayer: frontViewLayer)
            
            addConnection(frontConnection)
            self.frontCameraInputVideoPort = frontCameraPort
            frontCameraPort.isEnabled = false
        } catch {
            print("Cannot add back camera input")
        }
    }
    
    func setupBackCamera() {
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {return}
        backCaptureDevice = backCamera
        // set up back camera
        do {
            let backCameraInput = try AVCaptureDeviceInput(device: backCamera)
            backDeviceInput = backCameraInput
            currentDeviceInput = backCameraInput
            if canAddInput(backCameraInput) {
                addInputWithNoConnections(backCameraInput)
            } else {
                print("could not add front camera input")
            }
            
            guard let backCameraPort = backCameraInput.ports(for: .video, sourceDeviceType: backCamera.deviceType, sourceDevicePosition: backCamera.position).first else {return}
            
            if canAddOutput(backVideoDataOutput) {
                addOutputWithNoConnections(backVideoDataOutput)
            } else {
                print("Coud not add back cam video data output")
            }
            
            backVideoDataOutput.videoSettings = [:]
            backVideoDataOutput.setSampleBufferDelegate(self, queue: videoSessionQueue)
            
            let backOutputConnection = AVCaptureConnection(inputPorts: [backCameraPort], output: backVideoDataOutput)
            
            if canAddConnection(backOutputConnection) {
                addConnection(backOutputConnection)
            } else {
                print("Could not add back output connection")
            }
            backOutputConnection.videoOrientation = .portrait
            guard let backViewLayer = multiCamDelegate?.getBackViewLayer() else {return}
            let backConnection = AVCaptureConnection(inputPort: backCameraPort, videoPreviewLayer: backViewLayer)
            
            addConnection(backConnection)
            self.backCameraInputVideoPort = backCameraPort
        } catch {
            print("Cannot add back camera input")
        }
    }
    
    func capturePhoto() {
        isCapturePhoto = true
    }
    
    func record() {
       switch _captureState {
        
       case .idle:
      //      Animations.shared.animateRecordButton(videoButton: videoButton, captureButton: captureButton)
           _captureState = .start
            isRecording = true
     //       toggleButtons(isHidden: true)
       case .running:
            isRecording = false
           _captureState = .finished
     //       Animations.shared.animateMoveRecordButtonBack(button: videoButton)
     //       toggleButtons(isHidden: false)
       default:
            print("unknown capture state")
       }
               
    }
    
    func flipCamera() {
        guard let backVideoLayer = multiCamDelegate?.getBackViewLayer(), let frontVideoLayer = multiCamDelegate?.getFrontViewLayer(), let view = multiCamDelegate?.getView() else { return }
        print("Flip camera")
        if (currentCamera == .rear) {
            view.layer.insertSublayer(frontVideoLayer, at: UInt32(backVideoLayer.zPosition))
            backVideoLayer.removeFromSuperlayer()
            configureFrontCameraCapture()
            currentCamera = .front
        } else {
            view.layer.insertSublayer(backVideoLayer, at: UInt32(frontVideoLayer.zPosition))
            frontVideoLayer.removeFromSuperlayer()
            configureBackCameraCapture()
            currentCamera = .rear
        }
    }
    
    func configureFrontCameraCapture() {
        dualVideoSessionOutputQueue.async {
            self.currentDeviceInput = self.frontDeviceInput
            self.backCameraInputVideoPort?.isEnabled = false
            self.frontCameraInputVideoPort?.isEnabled = true
        }
        
    }
    
    func configureBackCameraCapture() {
        dualVideoSessionOutputQueue.async {
            self.currentDeviceInput = self.backDeviceInput
            self.backCameraInputVideoPort?.isEnabled = true
            self.frontCameraInputVideoPort?.isEnabled = false
        }
    }
    
    func toggleFlash() -> Flashmode {
        switch self.flashMode {
        case .off:
            self.flashMode = .auto
            return self.flashMode
        case .auto:
            self.flashMode = .on
            return flashMode
        case .on:
            self.flashMode = .off
            return flashMode
            
        }
    }
    
    func handleDualCameraDisplay() {
        guard let backVideoLayer = multiCamDelegate?.getBackViewLayer(), let frontVideoLayer = multiCamDelegate?.getFrontViewLayer(), let view = multiCamDelegate?.getView() else {return}
        if isInDualCameraMode {
            isInDualCameraMode = false
            //Turn off dual screen
            switch currentCamera {
            case .front:
                backVideoLayer.removeFromSuperlayer()
                frontVideoLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
                backVideoLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
                self.backCameraInputVideoPort?.isEnabled = true
                self.frontCameraInputVideoPort?.isEnabled = true
            case .rear:
                frontVideoLayer.removeFromSuperlayer()
                backVideoLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
                frontVideoLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
                self.backCameraInputVideoPort?.isEnabled = true
                self.frontCameraInputVideoPort?.isEnabled = true
            }
            
        } else {
            //Turn on dual screen
            isInDualCameraMode = true
            switch currentCamera {
            case .front:
                view.layer.insertSublayer(backVideoLayer, at: UInt32(frontVideoLayer.zPosition) + 1)
            case .rear:
                view.layer.insertSublayer(frontVideoLayer, at: UInt32(backVideoLayer.zPosition) + 1)
            }
            backVideoLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height/2)
            frontVideoLayer.frame = CGRect(x: 0, y: view.frame.height/2, width: view.frame.width, height: view.frame.height/2)
            self.backCameraInputVideoPort?.isEnabled = true
            self.frontCameraInputVideoPort?.isEnabled = true
        }
    }
    
    // MARK: KVO and Notifications
    private var keyValueObservations = [NSKeyValueObservation]()
    /// - Tag: ObserveInterruption
    public func addObservers() {
        
        //add observer to isRunning variable. This is to ensure the camera is not configured while session is not running
        let keyValueObservation = observe(\.isRunning, options: .new) { _, change in
            guard let isSessionRunning = change.newValue else { return }

            DispatchQueue.main.async {
                self.multiCamDelegate?.toggleButtons(isHidden: !isSessionRunning)
            }
        }
        
        /*
         A session can only run when the app is full screen. It will be interrupted
         in a multi-app layout, introduced in iOS 9, see also the documentation of
         AVCaptureSessionInterruptionReason. Add observers to handle these session
         interruptions and show a preview is paused message. See the documentation
         of AVCaptureSessionWasInterruptedNotification for other interruption reasons.
         */
        
        NotificationCenter.default.addObserver(self, selector: #selector(sessionRuntimeError), name: .AVCaptureSessionRuntimeError,object: self)
                
        NotificationCenter.default.addObserver(self, selector: #selector(sessionWasInterrupted), name: .AVCaptureSessionWasInterrupted, object: self)
                
        NotificationCenter.default.addObserver(self, selector: #selector(sessionInterruptionEnded), name: .AVCaptureSessionInterruptionEnded, object: self)
        
        keyValueObservations.append(keyValueObservation)

        NotificationCenter.default.addObserver(self, selector: #selector(subjectAreaDidChange), name: .AVCaptureDeviceSubjectAreaDidChange, object: frontCaptureDevice)
        NotificationCenter.default.addObserver(self, selector: #selector(subjectAreaDidChange), name: .AVCaptureDeviceSubjectAreaDidChange, object: backCaptureDevice)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionRuntimeError), name: .AVCaptureSessionRuntimeError, object: self)
    }
 
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
        for keyValueObservation in keyValueObservations {
            keyValueObservation.invalidate()
        }
        keyValueObservations.removeAll()
    }
    
    
    
}
