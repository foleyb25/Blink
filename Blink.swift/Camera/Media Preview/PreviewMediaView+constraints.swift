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
        
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: 60),
            cancelButton.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -30),
            cancelButton.heightAnchor.constraint(equalToConstant: 44),
            cancelButton.widthAnchor.constraint(equalToConstant: 44),
            
            sendButton.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -30),
            sendButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -35),
            sendButton.heightAnchor.constraint(equalToConstant: 44),
            sendButton.widthAnchor.constraint(equalToConstant: 44)
        ])
      
    }
}
