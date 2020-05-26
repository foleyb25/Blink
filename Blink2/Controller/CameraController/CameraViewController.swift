//
//  ViewController.swift
//  Blink2
//
//  Created by Brian Foley on 5/19/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//


//TODO: Add zoom gesture recognizer when video is recording
//      Remove other gesture recognizers from view on record

import UIKit
import AVFoundation
import Photos

/*
class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate, UIGestureRecognizerDelegate
*/
class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, UIGestureRecognizerDelegate {
    
    
    internal enum CameraSelection: String {
        /// Camera on the back of the device
        case rear = "rear"
        /// Camera on the front of the device
        case front = "front"
    }
    
    internal enum Flashmode: String {
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
    private var setupResult: SessionSetupResult = .success
    
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera], mediaType: .video, position: .unspecified)
    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!
    
    private let session = AVCaptureSession()
    private var isSessionRunning = false
    internal var isRecording = false
    // Communicate with the session and other session objects on this queue.
    internal let sessionQueue = DispatchQueue(label: "session_queue")
    // Communicate with live video recording
    internal let videoSessionQueue = DispatchQueue(label: "video_capture_session_queue")
    private var backgroundRecordingID: UIBackgroundTaskIdentifier?
    
    // Gesture Recognizer Variables
    internal var beginZoomScale = CGFloat(1.0)
    internal var zoomScale = CGFloat(1.0)
    internal var pinchGesture: UIPinchGestureRecognizer?
    internal var tapGesture: UITapGestureRecognizer?
    internal var focusTapGesture: UITapGestureRecognizer?
    internal var swipeRightGesture: UISwipeGestureRecognizer?
    internal var panGesture: UIGestureRecognizer?
    
    internal var previewLayer: AVCaptureVideoPreviewLayer = {
       let pl = AVCaptureVideoPreviewLayer()
        pl.videoGravity = .resizeAspectFill
        pl.frame = UIScreen.main.bounds
        pl.backgroundColor = UIColor.clear.cgColor
        return pl
    }()
    
    internal let previewView: UIView = {
        let pv = UIView()
        pv.translatesAutoresizingMaskIntoConstraints = false
        pv.frame = UIScreen.main.bounds
        return pv
    }()
    
    internal let captureButton: UIButton = {
       let button = UIButton()
        button.addTarget(self, action: #selector(capturePhotoPressed), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            button.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
        } else {
            button.setBackgroundImage(UIImage(named: "logo_no_bg"), for: .normal)
        }
        return button
    }()
    
    internal let timingLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    internal let videoButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(recordPressed), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 35/2
        button.layer.masksToBounds = true
        button.setTitle("", for: .normal)
        if #available(iOS 13.0, *) {
            button.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
        } else {
            button.setBackgroundImage(UIImage(named: "logo_no_bg"), for: .normal)
        }
        return button
    }()
    
    internal let cancelButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(cancelPressed), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            button.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
        } else {
            button.setBackgroundImage(UIImage(named: "logo_no_bg"), for: .normal)
        }
        return button
    }()
    
    internal let flipButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(flipCameraPressed), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            button.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
        } else {
            button.setBackgroundImage(UIImage(named: "logo_no_bg"), for: .normal)
        }
        return button
    }()
    
    internal let flashButton: UIButton = {
        print("Setting flash button options")
        let button = UIButton()
        button.addTarget(self, action: #selector(toggleFlashPressed), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Off", for: .normal)
        if #available(iOS 13.0, *) {
            button.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
        } else {
            button.setBackgroundImage(UIImage(named: "logo_no_bg"), for: .normal)
        }
        return button
    }()
    
    internal let sendButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(sendPressed), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            button.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
        } else {
            button.setBackgroundImage(UIImage(named: "logo_no_bg"), for: .normal)
        }
        return button
    }()
    
    // Navigation Bar buttons need to be set to lazy for them to work
    internal lazy var friendsButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(friendsButtonPressed), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            button.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
        } else {
            button.setBackgroundImage(UIImage(named: "logo_no_bg"), for: .normal)
        }
        return button
    }()

    internal lazy var genePoolButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(friendsButtonPressed), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            button.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
        } else {
            button.setBackgroundImage(UIImage(named: "logo_no_bg"), for: .normal)
        }
        return button
    }()
    
    // MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(previewView)
        view.addSubview(captureButton)
        view.addSubview(videoButton)
        view.addSubview(timingLabel)
        view.addSubview(cancelButton)
        view.addSubview(flipButton)
        view.addSubview(flashButton)
        view.addSubview(sendButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: friendsButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: genePoolButton)
        setButtonConstraints()
        
        
        
        //makes nav bar background invisible
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        
        sendButton.isEnabled = false
        cancelButton.isEnabled = false
        videoButton.isEnabled = false
        captureButton.isEnabled = false
        flashButton.isEnabled = false
        flipButton.isEnabled = false
        
        previewLayer.session = session
        
        previewView.layer.addSublayer(previewLayer)
        previewView.layer.addSublayer(imagePreview.layer)
        previewView.layer.addSublayer(playerLayer)
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
        togglePreviewMode(isInPreviewMode: false)
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
    
    
    // MARK: Toggle Preview Mode
    fileprivate func togglePreviewMode(isInPreviewMode: Bool) {
        if isInPreviewMode {
            captureButton.isHidden = true
            videoButton.isHidden = true
            flashButton.isHidden = true
            flipButton.isHidden = true
            cancelButton.isHidden = false
            sendButton.isHidden = false
            
            if let gesture = tapGesture {
                view.removeGestureRecognizer(gesture)
            }
            //previewAnimation()
            navigationController?.navigationBar.isHidden = true
        } else {
            captureButton.isHidden = false
            videoButton.isHidden = false
            flashButton.isHidden = false
            flipButton.isHidden = false
            cancelButton.isHidden = true
            sendButton.isHidden = true
            if let gesture = tapGesture {
                view.addGestureRecognizer(gesture)
            }
            //undoPreviewAnimation()
            navigationController?.navigationBar.isHidden = false
        }
    }
    
    private let photoOutput = AVCapturePhotoOutput()
    private var movieFileOutput: AVCaptureMovieFileOutput?
    
    var videoDataOutput: AVCaptureVideoDataOutput?
    var audioDataOutput: AVCaptureAudioDataOutput?
    
    // MARK: Session Management
    // Call this on the session queue.
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
        
        // Add the photo and video output.
        //let movieFileOutput = AVCaptureMovieFileOutput()
        let videoDataOutput = AVCaptureVideoDataOutput() // 2
        videoDataOutput.videoSettings = videoDataOutput.recommendedVideoSettingsForAssetWriter(writingTo: .mov)
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        //dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,]
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            self.videoDataOutput = videoDataOutput
        }
        
        let audioDataOutput = AVCaptureAudioDataOutput()
        audioDataOutput.recommendedAudioSettingsForAssetWriter(writingTo: .mov)
            
        if session.canAddOutput(audioDataOutput){
            session.addOutput(audioDataOutput)
            self.audioDataOutput = audioDataOutput
        }
            
            /*
            //Add movie file output
            photoOutput.isHighResolutionCaptureEnabled = true
            
            self.session.addOutput(movieFileOutput)
            self.session.sessionPreset = .high
            if let connection = movieFileOutput.connection(with: .video) {
                if connection.isVideoStabilizationSupported {
                    connection.preferredVideoStabilizationMode = .auto
                }
            }
            self.movieFileOutput = movieFileOutput
            */
        } else {
            print("Could not add photo output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        session.commitConfiguration()
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
                return CGAffineTransform(rotationAngle: .pi/2)
            case .portraitUpsideDown:
                return CGAffineTransform(rotationAngle: .pi)
            case .landscapeLeft:
                return .identity
            case .landscapeRight:
                return CGAffineTransform(rotationAngle: -.pi/2)
            default:
                return .identity
        }
    }

    // MARK: Flip Camera
    func flipCamera() {
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
                    self.beginZoomScale = CGFloat(1.0)
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
    
    
    lazy var imagePreview: UIImageView = {
        let viewItem = UIImageView()
        viewItem.frame = UIScreen.main.bounds
        viewItem.contentMode = .scaleAspectFill
        return viewItem
    }()
    
    private var image: UIImage?
    
    // MARK: Capturing Photos
    /// - Tag: CapturePhoto
    func capturePhoto() {
        //Capture picture in a thread
        if self.isRecording {
            return
        }
        
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
    
    
    var player: AVPlayer?
    
    fileprivate var playerLayer : AVPlayerLayer = {
        let layer = AVPlayerLayer()
        layer.frame = UIScreen.main.bounds
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    //MARK: Set Media Preview
    func setMediaPreview(isVideo: Bool) {
        print("setup media preview")
        //setup image preview
        if isVideo == false {
            if let imageTaken = image {
                imagePreview.image = imageTaken
            }
        //setup video preview
        } else {
            if let videoTaken = player {
                playerLayer.player = videoTaken
                playerLayer.frame = view.bounds
                playerLayer.videoGravity = .resizeAspectFill
            }
            if self.currentCamera == .front {
                self.playerLayer.setAffineTransform(CGAffineTransform(scaleX: -1.0, y: 1.0))
            }
            self.player!.play()
        }
        togglePreviewMode(isInPreviewMode: true)
    }
    
    // MARK: Recording Movies
    var videoWriter: AVAssetWriter!
    var videoWriterInput: AVAssetWriterInput!
    var audioWriterInput: AVAssetWriterInput!
    var sessionAtSourceTime: CMTime!
    var isWriting = false
    var hasStartedWritingCurrentVideo = false
    var fileName = ""
    var adapter: AVAssetWriterInputPixelBufferAdaptor?
    var _time: Double = 0
    enum _CaptureState {
              case idle, start, capturing, end
          }
    var _captureState = _CaptureState.idle
    
    func record() {
    
           switch _captureState {
            
           case .idle:
               videoDataOutput?.setSampleBufferDelegate(self, queue: videoSessionQueue)
               audioDataOutput?.setSampleBufferDelegate(self, queue: videoSessionQueue)
               _captureState = .start
           case .capturing:
                print("Setting end")
               _captureState = .end
           default:
                print("unknown capture state")
           }
                   
       }
    
    /*
    func record() {
        guard let movieFileOutput = self.movieFileOutput else {
            return
        }
    }
   
        /*MovieFileRecording*/
        sessionQueue.async {
            if !movieFileOutput.isRecording {
                if UIDevice.current.isMultitaskingSupported {
                    self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                }
                
                movieFileOutput.maxRecordedDuration = CMTime(seconds: 5.0, preferredTimescale: .max)
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
        
         DispatchQueue.main.async {
            Animations.animateRecordButton(videoButton: self.videoButton, captureButton: self.captureButton)
            
        }
    }
    
       
    
    /// - Tag: DidFinishRecording
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        
        DispatchQueue.main.async {
            self.isRecording = false
            print("moving back")
            Animations.animateMoveRecordButtonBack(button: self.videoButton)
            self.videoButton.layer.removeAllAnimations()
            self.view.addGestureRecognizer(self.tapGesture!)
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
                let player = AVPlayer(url: outputFileURL)
                player.actionAtItemEnd = .none
                self.player = player
                DispatchQueue.main.async{
                    self.setMediaPreview(isVideo: true)
                }
            } else {
                cleanup()
        }
        cleanup()
    }
       */
    
    // MARK: Cancel Capture
    func cancel() {
        if player != nil {
            player = nil
            videoWriter = nil
            videoWriterInput = nil
            playerLayer.player = nil
        } else {
            imagePreview.image = nil
        }
        togglePreviewMode(isInPreviewMode: false)
    }
    
    // MARK: Send Capture Content
    func send() {
    
    }
    
    private lazy var sideMenu: SideBarMenu = {
        let menu = SideBarMenu()
        menu.cameraViewController = self
        return menu
    }()
    
    func handleFriendsPressed() {
        sideMenu.showSideMenu()
    }
    
    func handleGenePoolPressed() {
        
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
    
    // MARK: Runtime Error Management
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

// MARK: Extension
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

   
