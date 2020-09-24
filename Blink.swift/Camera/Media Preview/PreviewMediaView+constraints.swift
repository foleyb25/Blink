//
//  PreviewMediaView+constraints.swift
//  Blink
//
//  Created by Brian Foley on 9/22/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

extension PreviewMediaView {
    
    func setupConstraints() {
        cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: 60).isActive = true
        cancelButton.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
        sendButton.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -35).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
    }
}
