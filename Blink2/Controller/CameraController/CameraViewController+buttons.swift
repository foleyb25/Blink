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
               imagePickerController.allowsEditing = true
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
            flashButton.setTitle(" Auto", for: .normal)
        case .auto:
            self.flashMode = .on
            flashButton.setTitle(" On", for: .normal)
        case .on:
            self.flashMode = .off
            flashButton.setTitle(" Off", for: .normal)
        }
    }
    
    @objc func sendPressed() {
        
    }
    
    @objc func friendsButtonPressed() {
        sideMenu.showSideMenu()
    }
    
    @objc func genePoolButtonPressed() {
        navigationController?.pushViewController(genePoolController, animated: true)
    }
    
    
    func previewAnimation() {
        UIView.animate(withDuration: 0.5, animations: {
            self.captureButton.frame.origin.y += 200
            self.videoButton.frame.origin.x -= 200
            self.flipButton.frame.origin.x += 200
            self.flashButton.frame.origin.x += 200
            self.view.layoutIfNeeded()
        })
    }
    
    func undoPreviewAnimation() {
        UIView.animate(withDuration: 0.5, animations: {
            self.captureButton.frame.origin.y -= 200
            self.videoButton.frame.origin.x += 200
            self.flipButton.frame.origin.x -= 200
            self.flashButton.frame.origin.x -= 200
            self.view.layoutIfNeeded()
        })
    }
    
}
