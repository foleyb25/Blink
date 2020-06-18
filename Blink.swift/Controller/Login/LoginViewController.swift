//
//  LoginViewController.swift
//  Blink2
//
//  Created by Brian Foley on 5/20/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    lazy var imageView: UIImageView = {
        let viewItem = UIImageView()
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        viewItem.backgroundColor = UIColor.clear
        viewItem.image = UIImage(named: "logo_no_bg")
        return viewItem
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
         stackView.distribution = .fillEqually
         stackView.axis = .vertical
         stackView.spacing = 10
         stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var emailField: UITextField = {
        let viewItem = UITextField()
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        viewItem.placeholder = "Email"
        viewItem.backgroundColor = UIColor(white: 0, alpha: 0.03)
        viewItem.borderStyle = .roundedRect
         viewItem.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return viewItem
    }()
    
    lazy var passwordField: UITextField = {
        let viewItem = UITextField()
        viewItem.textContentType = .password
        viewItem.isSecureTextEntry = true
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        viewItem.placeholder = "Password"
        viewItem.backgroundColor = UIColor(white: 0, alpha: 0.03)
        viewItem.borderStyle = .roundedRect
         viewItem.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return viewItem
    }()
    
    lazy var loginButton: UIButton = {
        let viewItem = UIButton()
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        viewItem.backgroundColor = UIColor.lightGray
        viewItem.setTitle("Login", for: .normal)
        viewItem.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        viewItem.setTitleColor(UIColor(white: 0, alpha: 0.3), for: .normal)
        viewItem.isEnabled = false
        viewItem.backgroundColor = UIColor(white: 1, alpha: 0.90)
        viewItem.layer.cornerRadius = 20
        viewItem.layer.masksToBounds = true
        return viewItem
    }()
    
    lazy var newUserButton: UIButton = {
       let viewItem = UIButton(type: .system)
        let attributedText = NSMutableAttributedString(string: "Need an Account? ", attributes: [NSAttributedString.Key.font:UIFont(name: "Georgia", size: 14)!, NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedText.append(NSAttributedString(string: "Register Here", attributes: [NSAttributedString.Key.foregroundColor: UIColor.blue, NSAttributedString.Key.font: UIFont(name: "Georgia", size: 14)!]))
        viewItem.setAttributedTitle(attributedText, for: .normal)
        viewItem.addTarget(self, action: #selector(presentRegistrationForm), for: .touchUpInside)
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        return viewItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.addSubview(imageView)
        view.addSubview(stackView)
        view.addSubview(loginButton)
        view.addSubview(newUserButton)
        stackView.addArrangedSubview(emailField)
        stackView.addArrangedSubview(passwordField)
        setupConstraints()
        addGestureRecognizers()
    }
    
    @objc func handleTextChange() {
           let isFormValid = !passwordField.text!.isEmpty && !emailField.text!.isEmpty
           if isFormValid {
               loginButton.setTitleColor(.white, for: .normal)
               loginButton.isEnabled = true
               loginButton.backgroundColor = UIColor(white: 0.5, alpha: 0.90)
           } else {
               loginButton.setTitleColor(UIColor(white: 0, alpha: 0.3), for: .normal)
               loginButton.isEnabled = false
               loginButton.backgroundColor = UIColor(white: 1, alpha: 0.90)
               
           }
       }
    
    lazy var registerController: RegisterForm = {
        let rc = RegisterForm()
        rc.modalPresentationStyle = .overCurrentContext
        return rc
    }()
    
    @objc func handleLogin() {
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty && !password.isEmpty else { return }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, err) in
            
            if let err = err {
                print("Failed to sign in with email:", err)
                return
            }
            
            guard let uid = user?.user.uid else { return }
            
            print("Successfully logged back in with user:", uid)
            Switcher.shared.updateRootVC()
            self.dismissController()
            
        })
    }
    
    func dismissController() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func presentRegistrationForm() {
        registerController.loginController = self
        present(registerController, animated: true, completion: nil)
    }
    
    func addGestureRecognizers() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    @objc func dismissKeyboard() {
        for textField in stackView.arrangedSubviews {
            textField.resignFirstResponder()
        }
    }
    
    var imageViewTopAnchor: NSLayoutConstraint?
    
    private func setupConstraints() {
       
        imageViewTopAnchor = imageView.topAnchor.constraint(equalTo: view.bottomAnchor)
        imageViewTopAnchor?.isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 170).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 170).isActive = true
        
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 15).isActive = true
        stackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -50).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 8).isActive = true
        loginButton.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        newUserButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newUserButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18).isActive = true
        newUserButton.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        newUserButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        self.view.layoutIfNeeded()
        
        imageViewTopAnchor?.isActive = false
        imageViewTopAnchor = imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100)
        imageViewTopAnchor?.isActive = true
        
        UIView.animate(withDuration: 1.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .beginFromCurrentState, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
