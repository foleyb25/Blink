//
//  CamerViewController+constraints.swift
//  Blink2
//
//  Created by Brian Foley on 5/20/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func setButtonConstraints() {
        
        captureButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -75).isActive = true
        captureButton.heightAnchor.constraint(equalToConstant: 75).isActive = true
        captureButton.widthAnchor.constraint(equalToConstant: 75).isActive = true
        
//        timingLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
//        timingLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -75).isActive = true
//        timingLabel.heightAnchor.constraint(equalToConstant: 75).isActive = true
//        timingLabel.widthAnchor.constraint(equalToConstant: 75).isActive = true
        
        videoButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor).isActive = true
        videoButton.rightAnchor.constraint(equalTo: captureButton.leftAnchor, constant: -35).isActive = true
        videoButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        videoButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        
        pickerButton.centerXAnchor.constraint(equalTo: captureButton.centerXAnchor).isActive = true
        pickerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true
        pickerButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        pickerButton.widthAnchor.constraint(equalToConstant: 35).isActive = true

        cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        cancelButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        
        flipButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor).isActive = true
        flipButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -35).isActive = true
        flipButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        flipButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        
        flashButton.centerXAnchor.constraint(equalTo: flipButton.centerXAnchor).isActive = true
        flashButton.bottomAnchor.constraint(equalTo: flipButton.topAnchor, constant: -35).isActive = true
        flashButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        flashButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        
        sendButton.centerXAnchor.constraint(equalTo: flipButton.centerXAnchor).isActive = true
        sendButton.topAnchor.constraint(equalTo: flipButton.bottomAnchor, constant: 35).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        
        friendsButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        friendsButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
        
        genePoolButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        genePoolButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
            
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func setupViewConstraints() {
        imagePreview.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        imagePreview.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        imagePreview.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor).isActive = true
        imagePreview.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
    }
    
    @objc func capturePhotoPressed() {
        captureButton.isHidden = true
        videoButton.isHidden = true
        flashButton.isHidden = true
        flipButton.isHidden = true
        navigationController?.navigationBar.isHidden = true
        capturePhoto()
    }
    
    @objc func recordPressed() {
        isRecording = true
        captureButton.isHidden = true
        flashButton.isHidden = true
        flipButton.isHidden = true
        navigationController?.navigationBar.isHidden = true
        view.removeGestureRecognizer(tapGesture!)
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
        cancel()
    }
    
    @objc func flipCameraPressed() {
        flipCamera()
    }
    
    @objc func toggleFlashPressed() {
        toggleFlash()
    }
    
    @objc func sendPressed() {
        send()
    }
    
    @objc func friendsButtonPressed() {
        handleFriendsPressed()
    }
    
    @objc func genePoolButtonPressed() {
        handleGenePoolPressed()
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
