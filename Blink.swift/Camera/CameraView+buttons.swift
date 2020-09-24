//
//  CamerViewController+constraints.swift
//  Blink2
//
//  Created by Brian Foley on 5/20/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//
//  Extension of CameraViewController to handle all button actions. Must inherit UIImagePickerControllerDelegate and UINavigation Controller delegate to handle the image picker
//
//  TODO: Add animations to button presses
//  TODO: Add video media data to SendMessageController and attch it in "Send"
//  TODO: Allow for videos to be selected from image picker

import UIKit
import AVFoundation

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /**
    Hides buttons to prevent crashes and calls capturePhoto in CameraViewController.swift class
    
     ## Notes
      Most of the work is handled in capturePhoto()
     
     - Warning: None
     - Parameter None
     - Returns: None
     
     ## Called in
     - CameraViewController.swift
    */
    @objc func capturePhotoPressed() {
        //Transfers to capture photo output delegate extension
        capturePhoto()
    }
    
    /**
     Hides buttons to prevent crashes and calls record() in CameraViewController.swift class
    
     ## Notes
      Most of the work is handled in record()
    
     - Warning: None
     - Parameter None
     - Returns: None
     
     ## Called in
     - CameraViewController.swift
    */
    @objc func recordPressed() {
        
        if let tapGesture = self.tapGesture {
            view.removeGestureRecognizer(tapGesture)
        }
        if let panGesture = self.recordPanGesture {
            view.addGestureRecognizer(panGesture)
        }
        
        //Transfers to capture video data delegate extension
        record()
    }
    
    
    /**
     Presents Image Picker with camera roll pictures. Authorization must be granted
    
     ## Notes
      Gestures are stored as global variables because they may need to be toggled on/off like the flip camera functionality needs to be toggled off when in preview mode.
    
     - Warning: None
     - Parameter None
     - Returns: None
     
     ## Called in
     - CameraViewController.swift
    */
    @objc func handleImagePickerButton() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    //@Override
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            togglePreviewMode(url: nil, image: editedImage)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            togglePreviewMode(url: nil, image: originalImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    /**
     Switches Capture Device (Front/Back Camera)
    
     - Warning: None
     - Parameter None
     - Returns: None
     
     ## Called in
     - CameraViewController.swift
    */
    @objc func flipCameraPressed() {
        guard let session = self.session else { return }
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
                    preferredDeviceType = .builtInWideAngleCamera
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
                    session.beginConfiguration()
                    // Remove the existing device input first, because AVCaptureSession doesn't support
                    // simultaneous use of the rear and front cameras.
                    session.removeInput(self.videoDeviceInput)
                    if session.canAddInput(videoDeviceInput) {
                        NotificationCenter.default.removeObserver(self, name: .AVCaptureDeviceSubjectAreaDidChange, object: currentVideoDevice)
                        NotificationCenter.default.addObserver(self, selector: #selector(self.subjectAreaDidChange), name: .AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput.device)
                        session.addInput(videoDeviceInput)
                        self.videoDeviceInput = videoDeviceInput
                    } else {
                        session.addInput(self.videoDeviceInput)
                    }
                    self.photoOutput.isDepthDataDeliveryEnabled = self.photoOutput.isDepthDataDeliverySupported
                    session.commitConfiguration()
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
    
    /**
     Toggles flash mode between Auto, On, or Off.
    
     - Warning: None
     - Parameter None
     - Returns: None
     
     ## Called in
     - CameraViewController.swift
    */
    @objc func toggleFlashPressed() {
        switch self.flashMode {
        case .off:
            self.flashMode = .auto
            flashButton.setBackgroundImage(UIImage(systemName: "bolt.circle"), for: .normal)
        case .auto:
            self.flashMode = .on
            flashButton.setBackgroundImage(UIImage(systemName: "bolt.fill"), for: .normal)
        case .on:
            self.flashMode = .off
            flashButton.setBackgroundImage(UIImage(systemName: "bolt.slash"), for: .normal)
        }
    }
    
    /**
     Presents Side Bar Menu
     
     - Warning: None
     - Parameter None
     - Returns: None
     
     ## Called in
     - CameraViewController.swift
    */
    @objc func friendsButtonPressed() {
        sideMenu.showSideMenu()
    }
    
    /**
     Presents Gene Pool Controller
     
     - Warning: None
     - Parameter None
     - Returns: None
     
     ## Called in
     - CameraViewController.swift
    */
    @objc func genePoolButtonPressed() {

        if Switcher.shared.settings?.genderId != nil {
            navigationController?.pushViewController(genePoolController, animated: true)
            return
        }
        
        let genePoolRegisterController = GenePoolRegisterController()
        genePoolRegisterController.cameraViewController = self
        navigationController?.pushViewController(genePoolRegisterController, animated: true)

    }
}
