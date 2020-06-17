//
//  Settings.swift
//  Blink2
//
//  Created by Brian Foley on 5/21/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit
import Firebase

class Settings: UIViewController {
    
    let signoutButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        button.setTitle("Log Out", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        view.addSubview(signoutButton)
        setupConstraints()
        
    }
    
    func setupConstraints() {
        signoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        signoutButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        signoutButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
            
            Switcher.updateRootVC()
            dismiss(animated: true, completion: nil)
            
        } catch let signOutErr {
            print("Failed to sign out:", signOutErr)
        }

    }
}
