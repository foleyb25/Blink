//
//  RegisterForm.swift
//  Blink2
//
//  Created by Brian Foley on 5/20/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

class RegisterForm: UIViewController {
    
    lazy var fieldContainerView: UIView = {
        let viewItem = UIView()
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        viewItem.backgroundColor = UIColor.clear
        return viewItem
    }()
    
    lazy var firstNameField: UITextField = {
           let viewItem = UITextField()
           viewItem.translatesAutoresizingMaskIntoConstraints = false
           viewItem.attributedPlaceholder = NSAttributedString(string: "First Name",
           attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 150/255, green: 150/255, blue: 150/255, alpha: 0.80)])
           return viewItem
       }()
       
       lazy var lastNameField: UITextField = {
           let viewItem = UITextField()
           viewItem.translatesAutoresizingMaskIntoConstraints = false
           viewItem.attributedPlaceholder = NSAttributedString(string: "Last Name",
                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 150/255, green: 150/255, blue: 150/255, alpha: 0.80)])
           return viewItem
       }()
       
       lazy var userNameField: UITextField = {
           let viewItem = UITextField()
           viewItem.translatesAutoresizingMaskIntoConstraints = false
           viewItem.attributedPlaceholder = NSAttributedString(string: "Username",
           attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 150/255, green: 150/255, blue: 150/255, alpha: 0.80)])
           return viewItem
       }()
       
       lazy var emailField: UITextField = {
           let viewItem = UITextField()
           viewItem.translatesAutoresizingMaskIntoConstraints = false
           viewItem.attributedPlaceholder = NSAttributedString(string: "Email",
           attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 150/255, green: 150/255, blue: 150/255, alpha: 0.80)])
           return viewItem
       }()
       
       lazy var passwordField: UITextField = {
           let viewItem = UITextField()
           viewItem.translatesAutoresizingMaskIntoConstraints = false
           viewItem.attributedPlaceholder = NSAttributedString(string: "Password",
           attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 150/255, green: 150/255, blue: 150/255, alpha: 0.80)])
           return viewItem
       }()
       
       lazy var passwordVerificationField: UITextField = {
           let viewItem = UITextField()
           viewItem.translatesAutoresizingMaskIntoConstraints = false
           viewItem.attributedPlaceholder = NSAttributedString(string: "Verify Password",
           attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 150/255, green: 150/255, blue: 150/255, alpha: 0.80)])
           return viewItem
       }()
    
    lazy var nameSeperatorLine: UIView = {
        let viewItem = UIView()
        viewItem.backgroundColor = UIColor.lightGray
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        return viewItem
    }()
    
    lazy var nameUsernameSeperatorLine: UIView = {
        let viewItem = UIView()
        viewItem.backgroundColor = UIColor.lightGray
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        return viewItem
    }()
    
    lazy var usernameEmailSeperatorLine: UIView = {
        let viewItem = UIView()
        viewItem.backgroundColor = UIColor.lightGray
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        return viewItem
    }()
    
    lazy var passwordEmailSeperatorLine: UIView = {
        let viewItem = UIView()
        viewItem.backgroundColor = UIColor.lightGray
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        return viewItem
    }()
    
    lazy var passwordVerificationSeperatorLine: UIView = {
        let viewItem = UIView()
        viewItem.backgroundColor = UIColor.lightGray
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        return viewItem
    }()
    
    lazy var registerButton: UIButton = {
        let viewItem = UIButton()
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        viewItem.backgroundColor = UIColor.lightGray
        viewItem.setTitle("Register", for: .normal)
        viewItem.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        viewItem.layer.cornerRadius = 20
        viewItem.layer.masksToBounds = true
        return viewItem
    }()
    
    lazy var cancelButton: UIButton = {
        let viewItem = UIButton()
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        viewItem.backgroundColor = UIColor.clear
        viewItem.setTitle("Cancel", for: .normal)
        viewItem.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return viewItem
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.addSubview(fieldContainerView)
        fieldContainerView.addSubview(firstNameField)
        fieldContainerView.addSubview(nameSeperatorLine)
        fieldContainerView.addSubview(lastNameField)
        fieldContainerView.addSubview(nameUsernameSeperatorLine)
        fieldContainerView.addSubview(userNameField)
        fieldContainerView.addSubview(usernameEmailSeperatorLine)
        fieldContainerView.addSubview(emailField)
        fieldContainerView.addSubview(passwordEmailSeperatorLine)
        fieldContainerView.addSubview(passwordField)
        fieldContainerView.addSubview(passwordVerificationSeperatorLine)
        fieldContainerView.addSubview(passwordVerificationField)
        view.addSubview(registerButton)
        view.addSubview(cancelButton)
        setupConstraints()
        addGestureRecognizers()
    }
    
    func addGestureRecognizers() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    @objc func dismissKeyboard() {
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        userNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        passwordVerificationField.resignFirstResponder()
    }
    
    @objc func handleRegister() {
        
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupConstraints() {
         
          //firstnamefield
          //lastnamefield
          //usernamefield
          //emailfield
          //passwordfield
          //passwordverificationfield
          
          fieldContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
          fieldContainerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
          fieldContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
          fieldContainerView.heightAnchor.constraint(equalToConstant: 300).isActive = true
          
          //fieldContainerSubviews
          firstNameField.centerXAnchor.constraint(equalTo: fieldContainerView.centerXAnchor).isActive = true
          firstNameField.topAnchor.constraint(equalTo: fieldContainerView.topAnchor).isActive = true
          firstNameField.widthAnchor.constraint(equalTo: fieldContainerView.widthAnchor, constant: -8).isActive = true
          firstNameField.heightAnchor.constraint(equalTo: fieldContainerView.heightAnchor, multiplier: 1/6).isActive = true
          
          nameSeperatorLine.centerXAnchor.constraint(equalTo: fieldContainerView.centerXAnchor).isActive = true
          nameSeperatorLine.topAnchor.constraint(equalTo: firstNameField.bottomAnchor).isActive = true
          nameSeperatorLine.widthAnchor.constraint(equalTo: fieldContainerView.widthAnchor).isActive = true
          nameSeperatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
          
          lastNameField.centerXAnchor.constraint(equalTo: fieldContainerView.centerXAnchor).isActive = true
          lastNameField.topAnchor.constraint(equalTo: nameSeperatorLine.bottomAnchor).isActive = true
          lastNameField.widthAnchor.constraint(equalTo: fieldContainerView.widthAnchor, constant: -8).isActive = true
          lastNameField.heightAnchor.constraint(equalTo: fieldContainerView.heightAnchor, multiplier: 1/6).isActive = true
          
          nameUsernameSeperatorLine.centerXAnchor.constraint(equalTo: fieldContainerView.centerXAnchor).isActive = true
          nameUsernameSeperatorLine.topAnchor.constraint(equalTo: lastNameField.bottomAnchor).isActive = true
          nameUsernameSeperatorLine.widthAnchor.constraint(equalTo: fieldContainerView.widthAnchor).isActive = true
          nameUsernameSeperatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
          
          userNameField.centerXAnchor.constraint(equalTo: fieldContainerView.centerXAnchor).isActive = true
          userNameField.topAnchor.constraint(equalTo: nameUsernameSeperatorLine.bottomAnchor).isActive = true
          userNameField.widthAnchor.constraint(equalTo: fieldContainerView.widthAnchor, constant: -8).isActive = true
          userNameField.heightAnchor.constraint(equalTo: fieldContainerView.heightAnchor, multiplier: 1/6).isActive = true
          
          usernameEmailSeperatorLine.centerXAnchor.constraint(equalTo: fieldContainerView.centerXAnchor).isActive = true
          usernameEmailSeperatorLine.topAnchor.constraint(equalTo: userNameField.bottomAnchor).isActive = true
          usernameEmailSeperatorLine.widthAnchor.constraint(equalTo: fieldContainerView.widthAnchor).isActive = true
          usernameEmailSeperatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
          
          emailField.centerXAnchor.constraint(equalTo: fieldContainerView.centerXAnchor).isActive = true
          emailField.topAnchor.constraint(equalTo: usernameEmailSeperatorLine.bottomAnchor).isActive = true
          emailField.widthAnchor.constraint(equalTo: fieldContainerView.widthAnchor, constant: -8).isActive = true
          emailField.heightAnchor.constraint(equalTo: fieldContainerView.heightAnchor, multiplier: 1/6).isActive = true
          
          passwordEmailSeperatorLine.centerXAnchor.constraint(equalTo: fieldContainerView.centerXAnchor).isActive = true
          passwordEmailSeperatorLine.topAnchor.constraint(equalTo: emailField.bottomAnchor).isActive = true
          passwordEmailSeperatorLine.widthAnchor.constraint(equalTo: fieldContainerView.widthAnchor).isActive = true
          passwordEmailSeperatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
          
          passwordField.centerXAnchor.constraint(equalTo: fieldContainerView.centerXAnchor).isActive = true
          passwordField.topAnchor.constraint(equalTo: passwordEmailSeperatorLine.bottomAnchor).isActive = true
          passwordField.widthAnchor.constraint(equalTo: fieldContainerView.widthAnchor, constant: -8).isActive = true
          passwordField.heightAnchor.constraint(equalTo: fieldContainerView.heightAnchor, multiplier: 1/6).isActive = true
          
          passwordVerificationSeperatorLine.centerXAnchor.constraint(equalTo: fieldContainerView.centerXAnchor).isActive = true
          passwordVerificationSeperatorLine.topAnchor.constraint(equalTo: passwordField.bottomAnchor).isActive = true
          passwordVerificationSeperatorLine.widthAnchor.constraint(equalTo: fieldContainerView.widthAnchor).isActive = true
          passwordVerificationSeperatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
          
          passwordVerificationField.centerXAnchor.constraint(equalTo: fieldContainerView.centerXAnchor).isActive = true
          passwordVerificationField.topAnchor.constraint(equalTo: passwordVerificationSeperatorLine.bottomAnchor).isActive = true
          passwordVerificationField.widthAnchor.constraint(equalTo: fieldContainerView.widthAnchor, constant: -8).isActive = true
          passwordVerificationField.heightAnchor.constraint(equalTo: fieldContainerView.heightAnchor, multiplier: 1/6).isActive = true
          
          registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
          registerButton.topAnchor.constraint(equalTo: fieldContainerView.bottomAnchor, constant: 8).isActive = true
          registerButton.widthAnchor.constraint(equalTo: fieldContainerView.widthAnchor).isActive = true
          registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
          cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
          cancelButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 8).isActive = true
          cancelButton.widthAnchor.constraint(equalTo: fieldContainerView.widthAnchor).isActive = true
          cancelButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        UIView.animate(withDuration: 0.33, delay: 0, options: .transitionFlipFromBottom, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
      }
}
