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
        
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -75),
            captureButton.heightAnchor.constraint(equalToConstant: 75),
            captureButton.widthAnchor.constraint(equalToConstant: 75),
            
            videoButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor),
            videoButton.rightAnchor.constraint(equalTo: captureButton.leftAnchor, constant: -35),
            videoButton.heightAnchor.constraint(equalToConstant: 44),
            videoButton.widthAnchor.constraint(equalToConstant: 44),
            
            pickerButton.centerXAnchor.constraint(equalTo: captureButton.centerXAnchor),
            pickerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            pickerButton.heightAnchor.constraint(equalToConstant: 44),
            pickerButton.widthAnchor.constraint(equalToConstant: 44),

            flipButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor),
            flipButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -35),
            flipButton.heightAnchor.constraint(equalToConstant: 44),
            flipButton.widthAnchor.constraint(equalToConstant: 44),
            
            flashButton.centerXAnchor.constraint(equalTo: flipButton.centerXAnchor),
            flashButton.bottomAnchor.constraint(equalTo: flipButton.topAnchor, constant: -35),
            flashButton.heightAnchor.constraint(equalToConstant: 44),
            flashButton.widthAnchor.constraint(equalToConstant: 44),
            
            friendsButton.heightAnchor.constraint(equalToConstant: 44),
            friendsButton.widthAnchor.constraint(equalToConstant: 44),
            
            genePoolButton.heightAnchor.constraint(equalToConstant: 44),
            genePoolButton.widthAnchor.constraint(equalToConstant: 44),
            
            dualCamDisplayButton.topAnchor.constraint(equalTo: flipButton.bottomAnchor, constant: 35),
            dualCamDisplayButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -35),
            dualCamDisplayButton.heightAnchor.constraint(equalToConstant: 44),
            dualCamDisplayButton.widthAnchor.constraint(equalToConstant: 44)
        ])

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}
