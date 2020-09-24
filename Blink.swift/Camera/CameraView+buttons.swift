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
