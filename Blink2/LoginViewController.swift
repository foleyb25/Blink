//
//  LoginViewController.swift
//  Blink2
//
//  Created by Brian Foley on 5/20/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

class LoginVIewController: UIViewController {
    
    lazy var imageView: UIImageView = {
        let viewItem = UIImageView()
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        viewItem.backgroundColor = UIColor.white
        return viewItem
    }()
    
    lazy var segmentedControlSwitch: UISegmentedControl = {
        let viewItem = UISegmentedControl()
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        viewItem.backgroundColor = UIColor.white
        return viewItem
    }()
    
    lazy var fieldContainerView: UIView = {
        let viewItem = UIView()
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        viewItem.backgroundColor = UIColor.white
        return viewItem
    }()
    
    lazy var firstNameField: UITextField = {
        let viewItem = UITextField()
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        viewItem.placeholder = "First Name"
        return viewItem
    }()
    
    lazy var lastNameField: UITextField = {
        let viewItem = UITextField()
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        viewItem.placeholder = "Last Name"
        return viewItem
    }()
    
    lazy var userNameField: UITextField = {
        let viewItem = UITextField()
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        viewItem.placeholder = "Username"
        return viewItem
    }()
    
    lazy var emailField: UITextField = {
        let viewItem = UITextField()
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        viewItem.placeholder = "Email"
        return viewItem
    }()
    
    lazy var passwordField: UITextField = {
        let viewItem = UITextField()
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        viewItem.placeholder = "Password"
        return viewItem
    }()
    
    lazy var passwordVerificationField: UITextField = {
        let viewItem = UITextField()
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        viewItem.placeholder = "Verify Password"
        return viewItem
    }()
    
    lazy var signLogButton: UIButton = {
        let viewItem = UIButton()
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        viewItem.backgroundColor = UIColor.white
        return viewItem
    }()
    
    /*
    lazy var fieldContanerSeperators: [UIView] = {
        var viewItem = [UIView]()
        let x = 0
        while x <  {
            let seperator = UIView()
            seperator.backgroundColor = .lightGray
            seperator.translatesAutoresizingMaskIntoConstraints = false
            viewItem.append(seperator)
        }
        return viewItem
    }()
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.view.backgroundColor = UIColor.blue
        view.addSubview(imageView)
        view.addSubview(segmentedControlSwitch)
        view.addSubview(fieldContainerView)
        view.addSubview(signLogButton)
        fieldContainerView.addSubview(firstNameField)
        fieldContainerView.addSubview(lastNameField)
        fieldContainerView.addSubview(userNameField)
        fieldContainerView.addSubview(emailField)
        fieldContainerView.addSubview(passwordField)
        fieldContainerView.addSubview(passwordVerificationField)
        print(fieldContainerView.subviews.count)
        setupConstraints()
    }
    
    private func setupConstraints() {
       
        //firstnamefield
        //lastnamefield
        //usernamefield
        //emailfield
        //passwordfield
        //passwordverificationfield
        
        fieldContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        fieldContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        fieldContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
        fieldContainerView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        //fieldContainerSubviews
        firstNameField.centerXAnchor.constraint(equalTo: fieldContainerView.centerXAnchor).isActive = true
        firstNameField.topAnchor.constraint(equalTo: fieldContainerView.topAnchor).isActive = true
        firstNameField.widthAnchor.constraint(equalTo: fieldContainerView.widthAnchor, constant: -8).isActive = true
        firstNameField.heightAnchor.constraint(equalTo: fieldContainerView.heightAnchor, multiplier: 1/6).isActive = true
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: firstNameField.frame.height - 1, width: firstNameField.frame.width, height: 11.0)
        bottomLine.backgroundColor = UIColor.black.cgColor
        firstNameField.borderStyle = UITextField.BorderStyle.none
        firstNameField.layer.addSublayer(bottomLine)
        firstNameField.layer.masksToBounds = true
        
        lastNameField.centerXAnchor.constraint(equalTo: fieldContainerView.centerXAnchor).isActive = true
        lastNameField.topAnchor.constraint(equalTo: firstNameField.bottomAnchor).isActive = true
        lastNameField.widthAnchor.constraint(equalTo: fieldContainerView.widthAnchor, constant: -8).isActive = true
        lastNameField.heightAnchor.constraint(equalTo: fieldContainerView.heightAnchor, multiplier: 1/6).isActive = true
        
        userNameField.centerXAnchor.constraint(equalTo: fieldContainerView.centerXAnchor).isActive = true
        userNameField.topAnchor.constraint(equalTo: lastNameField.bottomAnchor).isActive = true
        userNameField.widthAnchor.constraint(equalTo: fieldContainerView.widthAnchor, constant: -8).isActive = true
        userNameField.heightAnchor.constraint(equalTo: fieldContainerView.heightAnchor, multiplier: 1/6).isActive = true
        
        emailField.centerXAnchor.constraint(equalTo: fieldContainerView.centerXAnchor).isActive = true
        emailField.topAnchor.constraint(equalTo: userNameField.bottomAnchor).isActive = true
        emailField.widthAnchor.constraint(equalTo: fieldContainerView.widthAnchor, constant: -8).isActive = true
        emailField.heightAnchor.constraint(equalTo: fieldContainerView.heightAnchor, multiplier: 1/6).isActive = true
        
        passwordField.centerXAnchor.constraint(equalTo: fieldContainerView.centerXAnchor).isActive = true
        passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor).isActive = true
        passwordField.widthAnchor.constraint(equalTo: fieldContainerView.widthAnchor, constant: -8).isActive = true
        passwordField.heightAnchor.constraint(equalTo: fieldContainerView.heightAnchor, multiplier: 1/6).isActive = true
        
        passwordVerificationField.centerXAnchor.constraint(equalTo: fieldContainerView.centerXAnchor).isActive = true
        passwordVerificationField.topAnchor.constraint(equalTo: passwordField.bottomAnchor).isActive = true
        passwordVerificationField.widthAnchor.constraint(equalTo: fieldContainerView.widthAnchor, constant: -8).isActive = true
        passwordVerificationField.heightAnchor.constraint(equalTo: fieldContainerView.heightAnchor, multiplier: 1/6).isActive = true
        
        segmentedControlSwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        segmentedControlSwitch.bottomAnchor.constraint(equalTo: fieldContainerView.topAnchor, constant: -8).isActive = true
        segmentedControlSwitch.widthAnchor.constraint(equalTo: fieldContainerView.widthAnchor).isActive = true
        segmentedControlSwitch.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: segmentedControlSwitch.topAnchor, constant: -10).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 170).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 170).isActive = true
        
        signLogButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signLogButton.topAnchor.constraint(equalTo: fieldContainerView.bottomAnchor, constant: 8).isActive = true
        signLogButton.widthAnchor.constraint(equalTo: fieldContainerView.widthAnchor).isActive = true
        signLogButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        UIView.animate(withDuration: 0.85) {
            self.view.layoutIfNeeded()
        }
    }
}
