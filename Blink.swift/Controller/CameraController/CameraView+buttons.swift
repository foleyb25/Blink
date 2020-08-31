//
//  CamerViewController+constraints.swift
//  Blink2
//
//  Created by Brian Foley on 5/20/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    
    @objc func handleImagePickerButton() {
         let imagePickerController = UIImagePickerController()
               imagePickerController.delegate = self
               imagePickerController.allowsEditing = false
               present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.image = originalImage
        }
        
        setMediaPreview(isVideo: false)
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func cancelPressed() {
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
    
    @objc func flipCameraPressed() {
        flipCamera()
    }
    
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
    
    @objc func sendPressed() {
        lockPreviewMode = true
        let sendMessageController = SendMessageController()
        sendMessageController.image = self.image
        sendMessageController.camController = self
        self.navigationController?.pushViewController(sendMessageController, animated: true)
    }
    
    @objc func friendsButtonPressed() {
        sideMenu.showSideMenu()
    }
    
    @objc func genePoolButtonPressed() {
        let didRegister = Switcher.shared.currentUser?.didRegisterGP ?? false
        if didRegister {
            navigationController?.pushViewController(genePoolController, animated: true)
        } else {
            let genePoolRegisterController = GenePoolRegisterController()
            genePoolRegisterController.cameraViewController = self
            navigationController?.pushViewController(genePoolRegisterController, animated: true)
        }
    
       
        

    }
}
