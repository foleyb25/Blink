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
import Firebase

class CameraViewController: UIViewController, MultiCamSessionDelegate {

    var multiCamSession: MultiCamSession?
    
    var backViewLayer:AVCaptureVideoPreviewLayer = {
        let pl = AVCaptureVideoPreviewLayer()
        pl.videoGravity = .resizeAspectFill
        pl.frame = UIScreen.main.bounds
        pl.backgroundColor = UIColor.clear.cgColor
        return pl
    }()
    
    var frontViewLayer:AVCaptureVideoPreviewLayer = {
        let pl = AVCaptureVideoPreviewLayer()
        pl.videoGravity = .resizeAspectFill
        pl.frame = UIScreen.main.bounds
        pl.backgroundColor = UIColor.clear.cgColor
        return pl
    }()
    
    let captureButton: UIButton = {
       let button = UIButton()
        button.addTarget(self, action: #selector(capturePhotoPressed), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel!.font = UIFont.systemFont(ofSize: 20)
        button.tintColor = .white
        button.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
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
        button.setBackgroundImage(UIImage(systemName: "video.circle"), for: .normal)
        return button
    }()
    
    let pickerButton: UIButton = {
       let button = UIButton()
       button.addTarget(self, action: #selector(handleImagePickerButton), for: .touchDown)
       button.translatesAutoresizingMaskIntoConstraints = false
       button.titleLabel!.font = UIFont.systemFont(ofSize: 20)
       button.tintColor = .white
       button.setBackgroundImage(UIImage(systemName: "cube.box"), for: .normal)
       return button
    }()
    
    let flipButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(flipCameraPressed), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.setBackgroundImage(UIImage(systemName: "arrow.2.circlepath"), for: .normal)
        return button
    }()
    
    let flashButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(toggleFlashPressed), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.setBackgroundImage(UIImage(systemName: "bolt.circle"), for: .normal)
        return button
    }()
    
    let dualCamDisplayButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(handleDualCameraDisplay), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.setBackgroundImage(UIImage(systemName: "02.square"), for: .normal)
        return button
    }()
    
    // Navigation Bar buttons need to be set to lazy for them to work
    lazy var friendsButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(friendsButtonPressed), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.setImage(UIImage(systemName: "person.3.fill"), for: .normal)
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
    /*
     Setup the capture session.
     In general, it's not safe to mutate an AVCaptureSession or any of its
     inputs, outputs, or connections from multiple threads at the same time. This is
     why checkSetupResult is called from MultiCamSession through delegation. this is to ensure
     it is called on the dualcamsessionqueue and start session is not called before configuration
     is complete.
    
     configureCamerasInputOutput is called on dualsessioncameraqueue so the main queu jumps out of this
     call almost immmediately. This is true for all multicamera session configuration calls
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        //check to see if user is logged in
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                Switcher.shared.updateRootVC()
            }
            dismiss(animated: false, completion: nil)
        }
        multiCamSession = MultiCamSession()
        guard let mcs = multiCamSession else {return}
        mcs.multiCamDelegate = self
        backViewLayer.session = multiCamSession
        frontViewLayer.session = multiCamSession
        
        mcs.configureCamerasInputOutput()
        setupView()
    }
    
    //MARK: View Will Appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
    }
    
    //MARK: Setup View
    private func setupView() {
        guard let mcs = self.multiCamSession else {return}
        view.layer.addSublayer(backViewLayer)
        
        view.addSubview(dualCamDisplayButton)
        view.addSubview(captureButton)
        view.addSubview(pickerButton)
        view.addSubview(videoButton)
        view.addSubview(timingLabel)
        view.addSubview(flipButton)
        view.addSubview(flashButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: friendsButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: genePoolButton)
        setButtonConstraints()
        //add gesture recognizers dealing with the UI as well as the camera(s)
        mcs.addCameraGestureRecognizers()
        addUIGestureRecognizers()
            
    }
    
    private func setupNavBar() {
        //makes nav bar background invisible
        self.navigationController?.navigationBar.isHidden = isInPreviewMode
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
    }
    
    // MARK: Toggle Preview Mode
    var isInPreviewMode: Bool = false
    
    func togglePreviewMode(url: URL?, image: UIImage?) {
        isInPreviewMode = true
        self.navigationController?.navigationBar.isHidden = isInPreviewMode
        let previewMediaView = PreviewMediaView()
        previewMediaView.frame = UIScreen.main.bounds
        view.addSubview(previewMediaView)
        
        if let _url = url {
            previewMediaView.playerLayer.player = AVPlayer(url: _url)
            previewMediaView.url = url
            previewMediaView.playerLayer.frame = UIScreen.main.bounds
            previewMediaView.playerLayer.player?.actionAtItemEnd = .none
            previewMediaView.playerLayer.videoGravity = .resizeAspectFill
            previewMediaView.playerLayer.player!.play()
        } else if let _image = image {
            previewMediaView.imagePreview.image = _image
        }
    }
    
    func toggleButtons(isHidden: Bool) {
        captureButton.isHidden = isHidden
        flashButton.isHidden = isHidden
        flipButton.isHidden = isHidden
        pickerButton.isHidden = isHidden
        videoButton.isHidden = isHidden
        dualCamDisplayButton.isHidden = isHidden
    }
    
    //MARK: Delegate calls to multiCamSession
    func getView() -> UIView? {
        return view
    }
    
    func getFrontViewLayer() -> AVCaptureVideoPreviewLayer? {
        return frontViewLayer
    }
    
    func getBackViewLayer() -> AVCaptureVideoPreviewLayer? {
        return backViewLayer
    }
    
    func checkSetupResult() {
        guard let mcs = multiCamSession else {return}
        switch ( mcs.getSetupResult() ) {
        case .success:
            // Only setup observers and start the session if setup succeeded.
            if !mcs.audioAuthorized {
                let changePrivacySetting = "AVCam doesn't have permission to use the Microphone, please change privacy settings"
                let message = NSLocalizedString(changePrivacySetting, comment: "Alert message when the user has denied access to the Microphone")
                let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .`default`, handler: { _ in UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    }))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            mcs.addObservers()
            mcs.isSessionRunning = mcs.isRunning
            mcs.startRunning()
              
        case .camNotAuthorized:
            let changePrivacySetting = "AVCam doesn't have permission to use the camera, please change privacy settings"
            let message = NSLocalizedString(changePrivacySetting, comment: "Alert message when the user has denied access to the camera")
            let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .`default`, handler: { _ in UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                }))
            self.present(alertController, animated: true, completion: nil)
            return
        
        case .configurationFailed:
            let alertMsg = "Alert message when something goes wrong during capture session configuration"
            let message = NSLocalizedString("Unable to capture media", comment: alertMsg)
            let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    //End Delegate Calls
}

extension CameraViewController {
    
    func animateFlipCamera(from: AVCaptureVideoPreviewLayer, to: AVCaptureVideoPreviewLayer) {
        
//        UIView.animate(withDuration: 1) {
//            from.transform = CATransform3DMakeRotation(10, -1, -1, 0)
//        }
        
    }
}


   
