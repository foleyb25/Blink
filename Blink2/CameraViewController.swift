//
//  ViewController.swift
//  Blink2
//
//  Created by Brian Foley on 5/19/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//


import UIKit
import AVFoundation
import Photos

/*
class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate, UIGestureRecognizerDelegate
*/
class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate, UIGestureRecognizerDelegate {
    
    
    public enum CameraSelection: String {
        /// Camera on the back of the device
        case rear = "rear"
        /// Camera on the front of the device
        case front = "front"
    }
    
    public enum Flashmode: String {
        case auto = "auto"
        case on = "on"
        case off = "off"
    }
    
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    private(set) public var currentCamera = CameraSelection.rear
    private(set) public var flashMode = Flashmode.off
    fileprivate(set) public var panGesture: UIPanGestureRecognizer!
    public var pinchToZoom = true
    fileprivate var previousPanTranslation: CGFloat = 0.0
    public var swipeToZoomInverted = false
    fileprivate var zoomScale = CGFloat(1.0)
    public var maxZoomScale = CGFloat.greatestFiniteMagnitude
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera], mediaType: .video, position: .unspecified)
    public var swipeToZoom = true
    fileprivate var beginZoomScale = CGFloat(1.0)
    fileprivate(set) public var pinchGesture: UIPinchGestureRecognizer!
    private let session = AVCaptureSession()
    private var isSessionRunning = false
    private var isRecording = false
    // Communicate with the session and other session objects on this queue.
    private let sessionQueue = DispatchQueue(label: "session queue")
    private var setupResult: SessionSetupResult = .success
    private var image: UIImage?
    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!
    //private var movieFileOutput: AVCaptureMovieFileOutput?
    private var backgroundRecordingID: UIBackgroundTaskIdentifier?
    fileprivate var player: AVPlayer?
    fileprivate var playerLayer : AVPlayerLayer?
    private let photoOutput = AVCapturePhotoOutput()
    fileprivate var movieFileOutput: AVCaptureMovieFileOutput?
    
    var imagePreview: UIImageView?
    
    let previewView: UIView = {
        let pv = UIView()
        pv.translatesAutoresizingMaskIntoConstraints = false
        pv.frame = CGRect(x: 0,y: 0,width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height + 100)
        //pv.contentMode = .scaleAspectFill
        return pv
    }()
    
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    let captureButton: UIButton = {
       let button = UIButton()
        button.addTarget(self, action: #selector(capturePhotoPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
        return button
    }()
    
    let videoButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(recordPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
        return button
    }()
    
    let flipButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(flipCameraPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
        return button
    }()
    
    let flashButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(toggleFlashPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
        return button
    }()
    
    let sendButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(sendPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
        return button
    }()
    
        lazy var friendsButton: UIButton = {
            let button = UIButton()
            button.addTarget(self, action: #selector(friendsButtonPressed), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
            return button
        }()
    
        lazy var genePoolButton: UIButton = {
            let button = UIButton()
            button.addTarget(self, action: #selector(friendsButtonPressed), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
            return button
        }()
    
    
    
    // MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(previewView)
        view.addSubview(captureButton)
        view.addSubview(videoButton)
        view.addSubview(cancelButton)
        view.addSubview(flipButton)
        view.addSubview(flashButton)
        view.addSubview(sendButton)
        setButtonConstraints()
        self.deviceOrientation = .portrait
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: friendsButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: genePoolButton)
        self.navigationController?.navigationBar.backgroundColor = UIColor.green
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) 
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        
        sendButton.isEnabled = false
        cancelButton.isEnabled = false
        videoButton.isEnabled = false
        captureButton.isEnabled = false
        flashButton.isEnabled = false
        flipButton.isEnabled = false
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        let rootLayer :CALayer = self.previewView.layer
        rootLayer.masksToBounds=true
        previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(self.previewLayer)
        
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
             sessionQueue.suspend()
             AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                 if !granted {
                     self.setupResult = .notAuthorized
                 }
                 self.sessionQueue.resume()
             })
             /*
             Note that audio access will be implicitly requested when we
             create an AVCaptureDeviceInput for audio during session setup.
             */
        case .denied:
            print("denied")
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
        case .restricted:
            print("restricted")
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
        default:
            // The user has previously denied access.
            setupResult = .notAuthorized
        }
        /*
         Setup the capture session.
         In general, it's not safe to mutate an AVCaptureSession or any of its
         inputs, outputs, or connections from multiple threads at the same time.
        
         Don't perform these tasks on the main queue because
         AVCaptureSession.startRunning() is a blocking call, which can
         take a long time. Dispatch session setup to the sessionQueue, so
         that the main queue isn't blocked, which keeps the UI responsive.
         */
        sessionQueue.async {
            self.configureSession()
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                    // Only setup observers and start the session if setup succeeded.
                self.addObservers()
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
                    
            case .notAuthorized:
                DispatchQueue.main.async {
                    let changePrivacySetting = "AVCam doesn't have permission to use the camera, please change privacy settings"
                    let message = NSLocalizedString(changePrivacySetting, comment: "Alert message when the user has denied access to the camera")
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .`default`, handler: { _ in UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                        }))
                    self.present(alertController, animated: true, completion: nil)
                }
                    
            case .configurationFailed:
                DispatchQueue.main.async {
                    let alertMsg = "Alert message when something goes wrong during capture session configuration"
                    let message = NSLocalizedString("Unable to capture media", comment: alertMsg)
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        addGestureRecognizers()
        toggleButtons(isInPreviewMode: false)
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            print("VIEW TRANSITION")
           super.viewWillTransition(to: size, with: coordinator)
           
           if let videoPreviewLayerConnection = previewLayer.connection {
               let deviceOrientation = UIDevice.current.orientation
               guard let newVideoOrientation = AVCaptureVideoOrientation(deviceOrientation: deviceOrientation),
                   deviceOrientation.isPortrait || deviceOrientation.isLandscape else {
                       return
               }
               
               videoPreviewLayerConnection.videoOrientation = newVideoOrientation
           }
       }
    
    fileprivate func addGestureRecognizers() {
        
        //pinch to zoom
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoomGesture(pinch:)))
        pinchGesture.delegate = self
        self.view.addGestureRecognizer(pinchGesture)
        
        //double tap to switch camera
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(flipCameraPressed))
        tapGesture.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(tapGesture)
        
        let focusTapGesture = UITapGestureRecognizer(target: self, action: #selector(focusAndExposeTap(_:)))
        focusTapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(focusTapGesture)
    }
    
    @objc fileprivate func zoomGesture(pinch: UIPinchGestureRecognizer) {
        do {
            let captureDevice = self.videoDeviceInput.device
            try captureDevice.lockForConfiguration()
            zoomScale = min(maxZoomScale, max(1.0, min(beginZoomScale * pinch.scale,  captureDevice.activeFormat.videoMaxZoomFactor)))
            captureDevice.videoZoomFactor = zoomScale
            // Call Delegate function with current zoom scale
            captureDevice.unlockForConfiguration()
        } catch {
            print("Error locking configuration")
        }
    }
    
    @objc func focusAndExposeTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let devicePoint = previewLayer.captureDevicePointConverted(fromLayerPoint: gestureRecognizer.location(in: gestureRecognizer.view))
        focus(with: .autoFocus, exposureMode: .autoExpose, at: devicePoint, monitorSubjectAreaChange: true)
    }
    
    private func focus(with focusMode: AVCaptureDevice.FocusMode,
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
    
    // MARK: Toggle Buttons
    fileprivate func toggleButtons(isInPreviewMode: Bool) {
        if isInPreviewMode {
            captureButton.isHidden = true
            videoButton.isHidden = true
            flashButton.isHidden = true
            flipButton.isHidden = true
            cancelButton.isHidden = false
            sendButton.isHidden = false
            previewAnimation()
            navigationController?.navigationBar.isHidden = true
        } else {
            captureButton.isHidden = false
            videoButton.isHidden = false
            flashButton.isHidden = false
            flipButton.isHidden = false
            cancelButton.isHidden = true
            sendButton.isHidden = true
            undoPreviewAnimation()
            navigationController?.navigationBar.isHidden = false
        }
    }
    
    // MARK: Session Management
    // Call this on the session queue.
    /// - Tag: ConfigureSession
    private func configureSession() {
        
        if setupResult != .success {
            return
        }

        session.beginConfiguration()
        session.sessionPreset = .photo
        // Add video input.
        do {
            var defaultVideoDevice: AVCaptureDevice?
            
            // Choose the back dual camera, if available, otherwise default to a wide angle camera.
            
            if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                defaultVideoDevice = dualCameraDevice
            } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                // If a rear dual camera is not available, default to the rear wide angle camera.
                session.sessionPreset = AVCaptureSession.Preset(rawValue: AVCaptureSession.Preset.high.rawValue)
                defaultVideoDevice = backCameraDevice
            } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                // If the rear wide angle camera isn't available, default to the front wide angle camera.
                defaultVideoDevice = frontCameraDevice
            }
            guard let videoDevice = defaultVideoDevice else {
                print("Default video device is unavailable.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            } else {
                print("Couldn't add video device input to the session.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            print("Couldn't create video device input: \(error)")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        // Add an audio input device.
        do {
            let audioDevice = AVCaptureDevice.default(for: .audio)
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
            
            if session.canAddInput(audioDeviceInput) {
                session.addInput(audioDeviceInput)
            } else {
                print("Could not add audio device input to the session")
            }
        } catch {
            print("Could not create audio device input: \(error)")
        }
        // Add the photo output.
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
            
        } else {
            print("Could not add photo output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        configureVideoOutput()
        session.commitConfiguration()
    }
    
    
    fileprivate func configureVideoOutput() {
        let movieFileOutput = AVCaptureMovieFileOutput()
        if self.session.canAddOutput(movieFileOutput) {
            self.session.addOutput(movieFileOutput)
            self.session.sessionPreset = .high
            if let connection = movieFileOutput.connection(with: .video) {
                if connection.isVideoStabilizationSupported {
                    connection.preferredVideoStabilizationMode = .auto
                }
            }
        self.movieFileOutput = movieFileOutput
        }
    }
    
    fileprivate var deviceOrientation : UIDeviceOrientation?
    var shouldUseDeviceOrientation = true
    
   func getImageOrientation(forCamera: CameraSelection) -> UIImage.Orientation {
        guard shouldUseDeviceOrientation, let deviceOrientation = self.deviceOrientation else {
            return forCamera == .rear ? .right : .leftMirrored
    }
        switch deviceOrientation {
        case .landscapeLeft:
            return forCamera == .rear ? .up : .downMirrored
        case .landscapeRight:
            return forCamera == .rear ? .down : .upMirrored
        case .portraitUpsideDown:
            return forCamera == .rear ? .left : .rightMirrored
        default:
            return forCamera == .rear ? .right : .leftMirrored
        }
    }
    
    private func getVideoTransform(forCamera: CameraSelection) -> CGAffineTransform {
        guard let deviceOrientation = self.deviceOrientation else { return forCamera == .rear ? .init(rotationAngle: .pi/2) : .init(translationX: -1, y: 1) } //rotate 90 degrees clockwise, flip
        switch deviceOrientation {
            case .portrait:
                print("portrait")
                return CGAffineTransform(rotationAngle: .pi/2)
            case .portraitUpsideDown:
                return CGAffineTransform(rotationAngle: .pi)
            case .landscapeLeft:
                return .identity
            case .landscapeRight:
                return CGAffineTransform(rotationAngle: -.pi/2)
            default:
                print("identity")
                return .identity
        }
    }

    
    // MARK: Flip Camera
    
    func flipCamera() {
        captureButton.isEnabled = false
        sessionQueue.async {
            let currentVideoDevice = self.videoDeviceInput.device
            let currentPosition = currentVideoDevice.position
            let preferredPosition: AVCaptureDevice.Position
            let preferredDeviceType: AVCaptureDevice.DeviceType
            switch currentPosition {
            case .unspecified, .front:
                preferredPosition = .back
                preferredDeviceType = .builtInDualCamera
            case .back:
                preferredPosition = .front
                preferredDeviceType = .builtInTrueDepthCamera
            @unknown default:
                print("Unknown capture position. Defaulting to back, dual-camera.")
                preferredPosition = .back
                preferredDeviceType = .builtInDualCamera
            }
            let devices = self.videoDeviceDiscoverySession.devices
            var newVideoDevice: AVCaptureDevice? = nil
            // First, seek a device with both the preferred position and device type. Otherwise, seek a device with only the preferred position.
            if let device = devices.first(where: { $0.position == preferredPosition && $0.deviceType == preferredDeviceType }) {
                newVideoDevice = device
            } else if let device = devices.first(where: { $0.position == preferredPosition }) {
                newVideoDevice = device
            }
            if let videoDevice = newVideoDevice {
                do {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                    self.session.beginConfiguration()
                    // Remove the existing device input first, because AVCaptureSession doesn't support
                    // simultaneous use of the rear and front cameras.
                    self.session.removeInput(self.videoDeviceInput)
                    if self.session.canAddInput(videoDeviceInput) {
                        NotificationCenter.default.removeObserver(self, name: .AVCaptureDeviceSubjectAreaDidChange, object: currentVideoDevice)
                        NotificationCenter.default.addObserver(self, selector: #selector(self.subjectAreaDidChange), name: .AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput.device)
                        self.session.addInput(videoDeviceInput)
                        self.videoDeviceInput = videoDeviceInput
                    } else {
                        self.session.addInput(self.videoDeviceInput)
                    }
                    if let connection = self.movieFileOutput?.connection(with: .video) {
                        if connection.isVideoStabilizationSupported {
                            connection.preferredVideoStabilizationMode = .auto
                        }
                    }
                    self.photoOutput.isDepthDataDeliveryEnabled = self.photoOutput.isDepthDataDeliverySupported
                    self.session.commitConfiguration()
                } catch {
                    print("Error occurred while creating video device input: \(error)")
                }
            }
            if self.currentCamera == .front {
               self.currentCamera = .rear
            } else {
               self.currentCamera = .front
            }
            
        }
        captureButton.isEnabled = true
    }
  
    // MARK: Setting flash
    func toggleFlash() {
        switch self.flashMode {
        case .off:
            self.flashMode = .auto
            flashButton.setTitle(" Auto", for: .normal)
        case .auto:
            self.flashMode = .on
            flashButton.setTitle(" On", for: .normal)
        case .on:
            self.flashMode = .off
            flashButton.setTitle(" Off", for: .normal)
        }
    }
    
    // MARK: Capturing Photos
    /// - Tag: CapturePhoto
    func capturePhoto() {
        //Capture picture in a thread
        sessionQueue.async {
            var photoSettings = AVCapturePhotoSettings()
            
            // Capture HEIF photos when supported. Enable auto-flash and high-resolution photos.
            if  self.photoOutput.availablePhotoCodecTypes.contains(.jpeg) {
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            }
            
            if self.videoDeviceInput.device.isFlashAvailable {
                switch self.flashMode {
                case .auto:
                    photoSettings.flashMode = .auto
                case .on:
                    photoSettings.flashMode = .on
                case .off:
                    photoSettings.flashMode = .off
                }
            }
            
            photoSettings.isHighResolutionPhotoEnabled = true
            if !photoSettings.__availablePreviewPhotoPixelFormatTypes.isEmpty {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoSettings.__availablePreviewPhotoPixelFormatTypes.first!]
            }
            self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
           //photoProcessingHandler(false)
        if let imageData = photo.fileDataRepresentation() {
           let dataProvider = CGDataProvider(data: imageData as CFData)
           let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
            image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: getImageOrientation(forCamera: self.currentCamera))
            //
           DispatchQueue.main.async {
            self.setMediaPreview(isVideo: false)
           }
       }
    }
    
    //TODO: DISPLAY VIDEO PREVIEW
    fileprivate func setMediaPreview(isVideo: Bool) {
        
        if isVideo == false {
            imagePreview = UIImageView()
            imagePreview!.frame = previewView.bounds
            imagePreview!.contentMode = .scaleAspectFill
            imagePreview!.image = image
            previewView.layer.addSublayer(imagePreview!.layer)
        } else {
            self.playerLayer = AVPlayerLayer(player: self.player)
            playerLayer!.frame = self.view.bounds
            playerLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.previewLayer.addSublayer(playerLayer!)
            if self.currentCamera == .front {
                self.playerLayer!.setAffineTransform(CGAffineTransform(scaleX: -1.0, y: 1.0))
            }
            self.player!.play()
        }
        toggleButtons(isInPreviewMode: true)
    }
    
    // MARK: Recording Movies

    func record() {
        guard let movieFileOutput = self.movieFileOutput else {
            return
        }
        /*
        Disable the Camera button until recording finishes, and disable
        the Record button until recording starts or finishes.
        */
        
        flashButton.isHidden = true
        captureButton.isEnabled = false
        videoButton.isEnabled = false
        navigationController?.navigationBar.isHidden = true
        
        /*MovieFileRecording*/
        sessionQueue.async {
            if !movieFileOutput.isRecording {
                if UIDevice.current.isMultitaskingSupported {
                    self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                }
                // Update the orientation on the movie file output video connection before recording.
            let movieFileOutputConnection = movieFileOutput.connection(with: .video)
                movieFileOutputConnection?.videoOrientation = .portrait
                
            let availableVideoCodecTypes = movieFileOutput.availableVideoCodecTypes
                
            if availableVideoCodecTypes.contains(.hevc) {
                    movieFileOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.hevc], for: movieFileOutputConnection!)
            }
                // Start recording video to a temporary file.
                let outputFileName = NSUUID().uuidString
                let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
                movieFileOutput.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
            } else {
                movieFileOutput.stopRecording()
            }
        }
    }

    /// - Tag: DidStartRecording
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        // Enable the Record button to let the user stop recording.
        DispatchQueue.main.async {
            self.videoButton.isEnabled = true
            //self.recordButton.setImage(#imageLiteral(resourceName: "CaptureStop"), for: [])
        }
    }
        
    /// - Tag: DidFinishRecording
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        DispatchQueue.main.async {
            self.captureButton.isEnabled = true
        }
        // Note: Because we use a unique file path for each recording, a new recording won't overwrite a recording mid-save.
        
        func cleanup() {
            let path = outputFileURL.path
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                    print("Could not remove file at url: \(outputFileURL)")
                }
            }
            
            if let currentBackgroundRecordingID = backgroundRecordingID {
                backgroundRecordingID = UIBackgroundTaskIdentifier.invalid
                
                if currentBackgroundRecordingID != UIBackgroundTaskIdentifier.invalid {
                    UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
                }
            }
        }
            
        var success = true
            
            
            if error != nil {
                print("Movie file finishing error: \(String(describing: error))")
                success = (((error! as NSError).userInfo[AVErrorRecordingSuccessfullyFinishedKey] as AnyObject).boolValue)!
            }
            
            if success {
                print("SUCCESS")
                self.player = AVPlayer(url: outputFileURL)
                self.player!.actionAtItemEnd = .none
                DispatchQueue.main.async{
                    self.setMediaPreview(isVideo: true)
                }
            }
                
            // Enable the Camera and Record buttons to let the user switch camera and start another recording.
            DispatchQueue.main.async {
                // Only enable the ability to change camera if the device has more than one camera.
                self.videoButton.isEnabled = true
                //self.captureModeControl.isEnabled = true
                //self.recordButton.setImage(#imageLiteral(resourceName: "CaptureVideo"), for: [])
            }
    }
          
    // MARK: Cancel Capture

    
    func cancel() {
        if playerLayer != nil {
            self.playerLayer!.removeFromSuperlayer()
            self.playerLayer = nil
            self.player = nil
        } else {
            imagePreview!.image = nil
            imagePreview = nil
        //image = UIImage()
        }
        toggleButtons(isInPreviewMode: false)
    }
    
    // MARK: Send Capture Content

    func send() {
        
    }
    
    // MARK: KVO and Notifications
    private var keyValueObservations = [NSKeyValueObservation]()
    /// - Tag: ObserveInterruption
    private func addObservers() {
        
        let keyValueObservation = session.observe(\.isRunning, options: .new) { _, change in
            guard let isSessionRunning = change.newValue else { return }
            
            DispatchQueue.main.async {
                self.videoButton.isEnabled = isSessionRunning
                self.captureButton.isEnabled = isSessionRunning
                self.flipButton.isEnabled = isSessionRunning
                self.flashButton.isEnabled = isSessionRunning
                self.cancelButton.isEnabled = isSessionRunning
                self.sendButton.isEnabled = isSessionRunning
            }
        }
        keyValueObservations.append(keyValueObservation)
        let systemPressureStateObservation = observe(\.videoDeviceInput.device.systemPressureState, options: .new) { _, change in
            guard let systemPressureState = change.newValue else { return }
            self.setRecommendedFrameRateRangeForPressureState(systemPressureState: systemPressureState)
        }
        keyValueObservations.append(systemPressureStateObservation)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(subjectAreaDidChange), name: .AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput.device)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionRuntimeError), name: .AVCaptureSessionRuntimeError, object: session)
        /*
         A session can only run when the app is full screen. It will be interrupted
         in a multi-app layout, introduced in iOS 9, see also the documentation of
         AVCaptureSessionInterruptionReason. Add observers to handle these session
         interruptions and show a preview is paused message. See the documentation
         of AVCaptureSessionWasInterruptedNotification for other interruption reasons.
         */
        NotificationCenter.default.addObserver(self, selector: #selector(sessionWasInterrupted), name: .AVCaptureSessionWasInterrupted, object: session)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionInterruptionEnded), name: .AVCaptureSessionInterruptionEnded, object: session)
        
    }
 
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
        for keyValueObservation in keyValueObservations {
            keyValueObservation.invalidate()
        }
        keyValueObservations.removeAll()
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
           if let playerItem = notification.object as? AVPlayerItem {
               playerItem.seek(to: CMTime.zero, completionHandler: nil)
           }
    }
    
    /// - Tag: HandleRuntimeError
    @objc func sessionRuntimeError(notification: NSNotification) {
        print("Session Runtime Error")
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        
        print("Capture session runtime error: \(error)")
        // If media services were reset, and the last start succeeded, restart the session.
        if error.code == .mediaServicesWereReset {
            sessionQueue.async {
                if self.isSessionRunning {
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
                }
            }
        }
    }
    
    /// - Tag: HandleSystemPressure
    private func setRecommendedFrameRateRangeForPressureState(systemPressureState: AVCaptureDevice.SystemPressureState) {
        /*
         The frame rates used here are only for demonstration purposes.
         Your frame rate throttling may be different depending on your app's camera configuration.
         */
        let pressureLevel = systemPressureState.level
        if pressureLevel == .serious || pressureLevel == .critical {
            if self.movieFileOutput == nil || self.movieFileOutput?.isRecording == false {
                do {
                    try self.videoDeviceInput.device.lockForConfiguration()
                    print("WARNING: Reached elevated system pressure level: \(pressureLevel). Throttling frame rate.")
                    self.videoDeviceInput.device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 20)
                    self.videoDeviceInput.device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 15)
                    self.videoDeviceInput.device.unlockForConfiguration()
                } catch {
                    print("Could not lock device for configuration: \(error)")
                }
            }
        } else if pressureLevel == .shutdown {
            print("Session stopped running due to shutdown system pressure level.")
        }
    }
    
    /// - Tag: HandleInterruption
    @IBAction private func resumeInterruptedSession(_ resumeButton: UIButton) {
        sessionQueue.async {
            /*
             The session might fail to start running, for example, if a phone or FaceTime call is still
             using audio or video. This failure is communicated by the session posting a
             runtime error notification. To avoid repeatedly failing to start the session,
             only try to restart the session in the error handler if you aren't
             trying to resume the session.
             */
            self.session.startRunning()
            self.isSessionRunning = self.session.isRunning
            if !self.session.isRunning {
                DispatchQueue.main.async {
                    let message = NSLocalizedString("Unable to resume", comment: "Alert message when unable to resume the session running")
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    //self.resumeButton.isHidden = true
                }
            }
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
            } else if reason == .videoDeviceNotAvailableWithMultipleForegroundApps {
                print("reason")
            } else if reason == .videoDeviceNotAvailableDueToSystemPressure {
                print("Session stopped running due to shutdown system pressure level.")
            }
        }
    }
    
    @objc func sessionInterruptionEnded(notification: NSNotification) {
        print("Capture session interruption ended")
    }
}


extension AVCaptureDevice.DiscoverySession {
    var uniqueDevicePositionsCount: Int {
        
        var uniqueDevicePositions = [AVCaptureDevice.Position]()
        
        for device in devices where !uniqueDevicePositions.contains(device.position) {
            uniqueDevicePositions.append(device.position)
        }
        
        return uniqueDevicePositions.count
    }
}

extension AVCaptureVideoOrientation {
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeRight
        case .landscapeRight: self = .landscapeLeft
        default: return nil
        }
    }
    
    init?(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeLeft
        case .landscapeRight: self = .landscapeRight
        default: return nil
        }
    }
}

   
