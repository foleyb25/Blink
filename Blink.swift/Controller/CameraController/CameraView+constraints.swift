//
//  CameraViewController+constraints.swift
//  Blink
//
//  Created by Brian Foley on 6/17/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

extension CameraViewController {
    //MARK: Set up constraints
    func setButtonConstraints() {
        
        captureButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -75).isActive = true
        captureButton.heightAnchor.constraint(equalToConstant: 75).isActive = true
        captureButton.widthAnchor.constraint(equalToConstant: 75).isActive = true
    
        videoButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor).isActive = true
        videoButton.rightAnchor.constraint(equalTo: captureButton.leftAnchor, constant: -35).isActive = true
        videoButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        videoButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
        pickerButton.centerXAnchor.constraint(equalTo: captureButton.centerXAnchor).isActive = true
        pickerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true
        pickerButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        pickerButton.widthAnchor.constraint(equalToConstant: 44).isActive = true

        cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        cancelButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
        flipButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor).isActive = true
        flipButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -35).isActive = true
        flipButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        flipButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
        flashButton.centerXAnchor.constraint(equalTo: flipButton.centerXAnchor).isActive = true
        flashButton.bottomAnchor.constraint(equalTo: flipButton.topAnchor, constant: -35).isActive = true
        flashButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        flashButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
        sendButton.centerXAnchor.constraint(equalTo: flipButton.centerXAnchor).isActive = true
        sendButton.topAnchor.constraint(equalTo: flipButton.bottomAnchor, constant: 35).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
        friendsButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        friendsButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
        genePoolButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        genePoolButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
            
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}
