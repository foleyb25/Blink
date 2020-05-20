//
//  CamerViewController+constraints.swift
//  Blink2
//
//  Created by Brian Foley on 5/20/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

extension CameraViewController {
    
    func setButtonConstraints() {
        captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -75).isActive = true
        captureButton.heightAnchor.constraint(equalToConstant: 75).isActive = true
        captureButton.widthAnchor.constraint(equalToConstant: 75).isActive = true
        
        videoButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor).isActive = true
        videoButton.rightAnchor.constraint(equalTo: captureButton.leftAnchor, constant: -35).isActive = true
        videoButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        videoButton.widthAnchor.constraint(equalToConstant: 35).isActive = true

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
        
    }
    
    @objc func capturePhotoPressed() {
        capturePhoto()
    }
    
    @objc func recordPressed() {
        record()
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
        
    }
    
    @objc func genePoolButtonPressed() {
        
    }
    
    func previewAnimation() {
        UIView.animate(withDuration: 0.5, animations: {
            self.captureButton.frame.origin.y += 200
            self.videoButton.frame.origin.x -= 200
            self.flipButton.frame.origin.x += 200
            self.flashButton.frame.origin.x += 200
        })
    }
    
    func undoPreviewAnimation() {
        UIView.animate(withDuration: 0.5, animations: {
            self.captureButton.frame.origin.y -= 200
            self.videoButton.frame.origin.x += 200
            self.flipButton.frame.origin.x -= 200
            self.flashButton.frame.origin.x -= 200
        })
    }
}
