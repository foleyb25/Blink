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
        viewItem.backgroundColor = UIColor.clear
        viewItem.image = UIImage(named: "logo_no_bg")
        return viewItem
    }()
    
    lazy var fieldContainerView: UIView = {
        let viewItem = UIView()
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        viewItem.backgroundColor = UIColor.white
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
    
    lazy var loginButton: UIButton = {
        let viewItem = UIButton()
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        viewItem.backgroundColor = UIColor.lightGray
        viewItem.setTitle("Login", for: .normal)
        viewItem.addTarget(self, action: #selector(presentRegistrationForm), for: .touchUpInside)
        return viewItem
    }()
    
    lazy var newUserButton: UIButton = {
        let viewItem = UIButton()
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        viewItem.backgroundColor = UIColor.lightGray
        viewItem.setTitle("New User?", for: .normal)
        viewItem.addTarget(self, action: #selector(presentRegistrationForm), for: .touchUpInside)
        return viewItem
    }()
    
    lazy var passwordEmailSeperatorLine: UIView = {
        let viewItem = UIView()
        viewItem.backgroundColor = UIColor.lightGray
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        return viewItem
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.view.backgroundColor = UIColor.blue
        view.addSubview(imageView)
        view.addSubview(fieldContainerView)
        view.addSubview(loginButton)
        view.addSubview(newUserButton)
        fieldContainerView.addSubview(emailField)
        fieldContainerView.addSubview(passwordEmailSeperatorLine)
        fieldContainerView.addSubview(passwordField)
        setupConstraints()
        addGestureRecognizers()
        
    }
    
    @objc func presentRegistrationForm() {
        present(RegisterForm(), animated: true, completion: nil)
    }
    
    func addGestureRecognizers() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    @objc func dismissKeyboard() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
    private func setupConstraints() {
       
        //firstnamefield
        //lastnamefield
        //usernamefield
        //emailfield
        //passwordfield
        //passwordverificationfield
        
        fieldContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        fieldContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -70).isActive = true
        fieldContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
        fieldContainerView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        //fieldContainerSubviews
        emailField.centerXAnchor.constraint(equalTo: fieldContainerView.centerXAnchor).isActive = true
        emailField.topAnchor.constraint(equalTo: fieldContainerView.topAnchor).isActive = true
        emailField.widthAnchor.constraint(equalTo: fieldContainerView.widthAnchor, constant: -8).isActive = true
        emailField.heightAnchor.constraint(equalTo: fieldContainerView.heightAnchor, multiplier: 1/2).isActive = true
        
        passwordEmailSeperatorLine.centerXAnchor.constraint(equalTo: fieldContainerView.centerXAnchor).isActive = true
        passwordEmailSeperatorLine.topAnchor.constraint(equalTo: emailField.bottomAnchor).isActive = true
        passwordEmailSeperatorLine.widthAnchor.constraint(equalTo: fieldContainerView.widthAnchor).isActive = true
        passwordEmailSeperatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        passwordField.centerXAnchor.constraint(equalTo: fieldContainerView.centerXAnchor).isActive = true
        passwordField.topAnchor.constraint(equalTo: passwordEmailSeperatorLine.bottomAnchor).isActive = true
        passwordField.widthAnchor.constraint(equalTo: fieldContainerView.widthAnchor, constant: -8).isActive = true
        passwordField.heightAnchor.constraint(equalTo: fieldContainerView.heightAnchor, multiplier: 1/2).isActive = true
        
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: fieldContainerView.topAnchor, constant: -20).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 170).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 170).isActive = true
        
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.topAnchor.constraint(equalTo: fieldContainerView.bottomAnchor, constant: 8).isActive = true
        loginButton.widthAnchor.constraint(equalTo: fieldContainerView.widthAnchor).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        newUserButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newUserButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 8).isActive = true
        newUserButton.widthAnchor.constraint(equalTo: fieldContainerView.widthAnchor).isActive = true
        newUserButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        UIView.animate(withDuration: 0.85) {
            self.view.layoutIfNeeded()
        }
    }
}
