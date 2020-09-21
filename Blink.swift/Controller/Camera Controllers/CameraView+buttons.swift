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
        captureButton.isHidden = true
        videoButton.isHidden = true
        flashButton.isHidden = true
        flipButton.isHidden = true
        pickerButton.isHidden = true
        navigationController?.navigationBar.isHidden = true
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
        isRecording = true
        captureButton.isHidden = true
        flashButton.isHidden = true
        flipButton.isHidden = true
        pickerButton.isHidden = true
        navigationController?.navigationBar.isHidden = true
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
            self.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.image = originalImage
        }
        
        setMediaPreview(url: nil)
        
        dismiss(animated: true, completion: nil)
    }
    
    /**
     Removes photo or video from media preview layer
    
     ## Notes
      Cancel button is displayed only in preview mode. Setting values to nil makes preview layer(s) transparent
    
     - Warning: None
     - Parameter None
     - Returns: None
     
     ## Called in
     - CameraViewController.swift
    */
    @objc func cancelPressed() {
        if player != nil {
            player = nil
            videoWriter = nil
            videoWriterInput = nil
            // playerLayer is the video preview layer
            playerLayer.player = nil
        } else {
            // image preview is the image preview layer
            imagePreview.image = nil
        }
        togglePreviewMode(isInPreviewMode: false)
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
        flipCamera()
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
     Sends media content to sendMessageController and presents message controller
     
    ## Notes
     Displays only in preview mode
     
     - Warning: None
     - Parameter None
     - Returns: None
     
     ## Called in
     - CameraViewController.swift
    */
    @objc func sendPressed() {
        lockPreviewMode = true
        let sendMessageController = SendMessageController()
        sendMessageController.image = self.image
        sendMessageController.camController = self
        self.navigationController?.pushViewController(sendMessageController, animated: true)
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
        print(Switcher.shared.settings?.genderId)
        if Switcher.shared.settings?.genderId != nil {
            navigationController?.pushViewController(genePoolController, animated: true)
            return
        }
        
        let genePoolRegisterController = GenePoolRegisterController()
        genePoolRegisterController.cameraViewController = self
        navigationController?.pushViewController(genePoolRegisterController, animated: true)

    }
}
