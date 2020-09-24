//
//  ViewController.swift
//  Blink2
//
//  Created by Brian Foley on 5/19/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//


//TODO: Fix simultaneous button press crash. start at +buttons extension
//TODO: Continuous recording with AVAsset Writer while recording video and flipping camera
//TODO: Make custom Icons for buttons
//TODO: Enable users to add text/drawing/color pallet to captured media in preview mode
//TODO: Add left swipe navigation to open GenePool Controller
//TODO: Add up swipe to view camera Roll pictures :: Create custom collection view (see instagram firebase tutorial)

import UIKit
import AVFoundation
import Photos
import Firebase

/*
class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate, UIGestureRecognizerDelegate
*/
class CameraViewController: UIViewController {
    
    enum CameraSelection: String {
        /// Camera on the back of the device
        case rear = "rear"
        /// Camera on the front of the device
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
    
    enum _CaptureState {
        case idle
        case start
        case capturing
        case end
        case finished
    }
    
    var audioAuthorized = true
    
    public var currentCamera = CameraSelection.rear
    public var flashMode = Flashmode.auto
    public var setupResult: SessionSetupResult = .success
    
    public let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera], mediaType: .video, position: .unspecified)
    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!
    public private(set) var session: AVCaptureSession? //public getter internal setter
    public var isSessionRunning = false
    var isRecording = false
    // Communicate with the session and other session objects on this queue.
    let sessionQueue = DispatchQueue(label: "session_queue")
    // Communicate with live video recording
    let videoSessionQueue = DispatchQueue(label: "video_capture_session_queue")
    var backgroundRecordingID: UIBackgroundTaskIdentifier?
    
    // Gesture Recognizer Variables
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
    var videoWriter: AVAssetWriter!
    var videoWriterInput: AVAssetWriterInput!
    var audioWriterInput: AVAssetWriterInput!
    var fileName = ""
    var adapter: AVAssetWriterInputPixelBufferAdaptor?
    var _time: Double = 0
    
    var _captureState = _CaptureState.idle
    
    var previewLayer: AVCaptureVideoPreviewLayer = {
       let pl = AVCaptureVideoPreviewLayer()
        pl.videoGravity = .resizeAspectFill
        pl.frame = UIScreen.main.bounds
        pl.backgroundColor = UIColor.clear.cgColor
        return pl
    }()
    
    let previewView: UIView = {
        let pv = UIView()
        pv.translatesAutoresizingMaskIntoConstraints = false
        pv.frame = UIScreen.main.bounds
        return pv
    }()
    
    let captureButton: UIButton = {
       let button = UIButton()
        button.addTarget(self, action: #selector(capturePhotoPressed), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel!.font = UIFont.systemFont(ofSize: 20)
        button.tintColor = .white
        if #available(iOS 13.0, *) {
            button.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
        } else {
            button.setBackgroundImage(UIImage(named: "logo_no_bg"), for: .normal)
        }
        return button
    }()
    
    let timingLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let videoButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(recordPressed), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 35/2
        button.layer.masksToBounds = true
        button.setTitle("", for: .normal)
        button.tintColor = .white
        if #available(iOS 13.0, *) {
            button.setBackgroundImage(UIImage(systemName: "video.circle"), for: .normal)

        } else {
            button.setBackgroundImage(UIImage(named: "logo_no_bg"), for: .normal)
        }
        return button
    }()
    
    let pickerButton: UIButton = {
       let button = UIButton()
       button.addTarget(self, action: #selector(handleImagePickerButton), for: .touchDown)
       button.translatesAutoresizingMaskIntoConstraints = false
       button.titleLabel!.font = UIFont.systemFont(ofSize: 20)
       button.tintColor = .white
       if #available(iOS 13.0, *) {
           button.setBackgroundImage(UIImage(systemName: "cube.box"), for: .normal)
       } else {
           button.setBackgroundImage(UIImage(named: "logo_no_bg"), for: .normal)
       }
       return button
    }()
    
    let flipButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(flipCameraPressed), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        if #available(iOS 13.0, *) {
            button.setBackgroundImage(UIImage(systemName: "arrow.2.circlepath"), for: .normal)
        } else {
            button.setBackgroundImage(UIImage(named: "logo_no_bg"), for: .normal)
        }
        return button
    }()
    
    let flashButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(toggleFlashPressed), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        if #available(iOS 13.0, *) {
            button.setBackgroundImage(UIImage(systemName: "bolt.circle"), for: .normal)
        } else {
            button.setBackgroundImage(UIImage(named: "logo_no_bg"), for: .normal)
        }
        return button
    }()
    
    // Navigation Bar buttons need to be set to lazy for them to work
    lazy var friendsButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(friendsButtonPressed), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "person.3.fill"), for: .normal)
        } else {
            button.setImage(UIImage(named: "logo_no_bg"), for: .normal)
        }
        return button
    }()

    lazy var genePoolButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(genePoolButtonPressed), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.setBackgroundImage(UIImage(named: "gene_pool_button"), for: .normal)
        return button
    }()
    
    //Views presented on swipe or nav bar button press
    lazy var sideMenu: SideBarMenuController = {
        let menu = SideBarMenuController()
        menu.cameraViewController = self
        return menu
    }()
    
    lazy var genePoolController: GenePoolViewController = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionHeadersPinToVisibleBounds = true
        let genePoolController = GenePoolViewController()
        return genePoolController
    }()
    
    // MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //check to see if user is logged in
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                Switcher.shared.updateRootVC()
            }
            dismiss(animated: false, completion: nil)
        }
        session = AVCaptureSession()
        setupView()
        
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
                     self.setupResult = .camNotAuthorized
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
                    self.setupResult = .camNotAuthorized
                }
                self.sessionQueue.resume()
            })
        case .restricted:
            print("restricted")
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .camNotAuthorized
                }
                self.sessionQueue.resume()
            })
        default:
            // The user has previously denied access.
            setupResult = .camNotAuthorized
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
    
    //MARK: View Will Appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
 
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                    // Only setup observers and start the session if setup succeeded.
                if !self.audioAuthorized {
                    DispatchQueue.main.async {
                        let changePrivacySetting = "AVCam doesn't have permission to use the Microphone, please change privacy settings"
                        let message = NSLocalizedString(changePrivacySetting, comment: "Alert message when the user has denied access to the Microphone")
                        let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
                        alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .`default`, handler: { _ in UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                            }))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                self.addObservers()
                guard let session = self.session else { return }
                session.startRunning()
                self.isSessionRunning = session.isRunning
                    
            case .camNotAuthorized:
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
    }
    
    //MARK: Setup View
    fileprivate func setupView() {
        view.addSubview(previewView)
        view.addSubview(captureButton)
        view.addSubview(pickerButton)
        view.addSubview(videoButton)
        view.addSubview(timingLabel)
        view.addSubview(flipButton)
        view.addSubview(flashButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: friendsButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: genePoolButton)
        setButtonConstraints()
        addGestureRecognizers()
        
        videoButton.isEnabled = false
        captureButton.isEnabled = false
        flashButton.isEnabled = false
        flipButton.isEnabled = false
        pickerButton.isEnabled = false
        
        previewLayer.session = session
        
        previewView.layer.addSublayer(previewLayer)
    }
    
    
    
    internal func setupNavBar() {
        //makes nav bar background invisible
        self.navigationController?.navigationBar.isHidden = isInPreviewMode
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
    }
    
    // MARK: Toggle Preview Mode
    var isInPreviewMode: Bool = false
    
    internal func togglePreviewMode(url: URL?, image: UIImage?) {
        isInPreviewMode = true
        self.navigationController?.navigationBar.isHidden = isInPreviewMode
        let previewMediaView = PreviewMediaView()
        previewMediaView.frame = UIScreen.main.bounds
        view.addSubview(previewMediaView)
        
        if let _url = url {
            previewMediaView.playerLayer.player = AVPlayer(url: _url)
            previewMediaView.playerLayer.frame = UIScreen.main.bounds
            previewMediaView.playerLayer.player?.actionAtItemEnd = .none
            previewMediaView.playerLayer.videoGravity = .resizeAspectFill
            previewMediaView.playerLayer.player!.play()
        } else if let _image = image {
            previewMediaView.imagePreview.image = _image
        }
        
    }
    
    let photoOutput = AVCapturePhotoOutput()
    var videoDataOutput = AVCaptureVideoDataOutput()
    var audioDataOutput = AVCaptureAudioDataOutput()

    // MARK: KVO and Notifications
    private var keyValueObservations = [NSKeyValueObservation]()
    /// - Tag: ObserveInterruption
    private func addObservers() {
        guard let session = self.session else { return }
        let keyValueObservation = session.observe(\.isRunning, options: .new) { _, change in
            guard let isSessionRunning = change.newValue else { return }
            
            DispatchQueue.main.async {
                self.videoButton.isEnabled = isSessionRunning
                self.captureButton.isEnabled = isSessionRunning
                self.flipButton.isEnabled = isSessionRunning
                self.flashButton.isEnabled = isSessionRunning
             //   self.cancelButton.isEnabled = isSessionRunning
             //   self.sendButton.isEnabled = isSessionRunning
                self.pickerButton.isEnabled = isSessionRunning
            }
        }
        
        keyValueObservations.append(keyValueObservation)
        let systemPressureStateObservation = observe(\.videoDeviceInput.device.systemPressureState, options: .new) { _, change in
            guard let systemPressureState = change.newValue else { return }
            self.setRecommendedFrameRateRangeForPressureState(systemPressureState: systemPressureState)
        }
        keyValueObservations.append(systemPressureStateObservation)
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
    
}




   
