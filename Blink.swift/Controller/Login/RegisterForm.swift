//
//  RegisterForm.swift
//  Blink2
//
//  Created by Brian Foley on 5/20/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit
import Firebase

class RegisterForm: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .large)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.backgroundColor = UIColor(white: 0, alpha: 0.5)
        aiv.isOpaque = true
        return aiv
    }()
    
    
    let imageSelector: UIButton = {
        let viewItem = UIButton(type: .system)
        viewItem.setImage(UIImage(named: "missing_profile_image")?.withRenderingMode(.alwaysOriginal), for: .normal)
        viewItem.layer.cornerRadius = 60
        viewItem.layer.masksToBounds = true
        viewItem.imageView?.clipsToBounds = true
        viewItem.translatesAutoresizingMaskIntoConstraints = false
        viewItem.addTarget(self, action: #selector(handleImageSelector), for: .touchUpInside)
        return viewItem
    }()
    
    let stackView: UIStackView = {
            let viewItem = UIStackView()
            viewItem.distribution = .fillEqually
            viewItem.axis = .vertical
            viewItem.spacing = 10
            viewItem.translatesAutoresizingMaskIntoConstraints = false
            return viewItem
    }()

       lazy var userNameField: UITextField = {
           let viewItem = UITextField()
        
            viewItem.translatesAutoresizingMaskIntoConstraints = false
            viewItem.attributedPlaceholder = NSAttributedString(string: "Username",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 150/255, green: 150/255, blue: 150/255, alpha: 0.80)])
            viewItem.textColor = UIColor(white: 1, alpha: 1)
            viewItem.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
            viewItem.backgroundColor = UIColor(white: 0.2, alpha: 1)
            viewItem.borderStyle = .roundedRect
            return viewItem
       }()
       
       lazy var emailField: UITextField = {
            let viewItem = UITextField()
            viewItem.translatesAutoresizingMaskIntoConstraints = false
            viewItem.attributedPlaceholder = NSAttributedString(string: "Email",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 150/255, green: 150/255, blue: 150/255, alpha: 0.80)])
            viewItem.textColor = UIColor(white: 1, alpha: 1)
            viewItem.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
            viewItem.textContentType = .emailAddress
            viewItem.backgroundColor = UIColor(white: 0.2, alpha: 1)
            viewItem.borderStyle = .roundedRect
           return viewItem
       }()
       
       lazy var passwordField: UITextField = {
            let viewItem = UITextField()
            viewItem.textContentType = .password
            viewItem.translatesAutoresizingMaskIntoConstraints = false
            viewItem.attributedPlaceholder = NSAttributedString(string: "Password",
           attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 150/255, green: 150/255, blue: 150/255, alpha: 0.80)])
            viewItem.textColor = UIColor(white: 1, alpha: 1)
            viewItem.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
            viewItem.isSecureTextEntry = true
            viewItem.backgroundColor = UIColor(white: 0.2, alpha: 1)
            viewItem.borderStyle = .roundedRect
           return viewItem
       }()
       
       lazy var passwordVerificationField: UITextField = {
            let viewItem = UITextField()
            viewItem.textContentType = .password
            viewItem.translatesAutoresizingMaskIntoConstraints = false
            viewItem.attributedPlaceholder = NSAttributedString(string: "Verify Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 150/255, green: 150/255, blue: 150/255, alpha: 0.80)])
        viewItem.textColor = UIColor(white: 1, alpha: 1)
            viewItem.isSecureTextEntry = true
            viewItem.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        viewItem.backgroundColor = UIColor(white: 0.2, alpha: 1)
            viewItem.borderStyle = .roundedRect
           return viewItem
       }()
    
    let registerButton: UIButton = {
            let viewItem = UIButton(type: .system)
            viewItem.translatesAutoresizingMaskIntoConstraints = false
            viewItem.isEnabled = false
            viewItem.backgroundColor = UIColor(white: 1, alpha: 0.90)
            viewItem.setTitle("Register", for: .normal)
            viewItem.setTitleColor(UIColor(white: 0, alpha: 0.3), for: .normal)
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var loginController: LoginViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .black
        addBlurEffect()
        view.addSubview(imageSelector)
        view.addSubview(stackView)
        stackView.addArrangedSubview(userNameField)
        stackView.addArrangedSubview(emailField)
        stackView.addArrangedSubview(passwordField)
        stackView.addArrangedSubview(passwordVerificationField)
        view.addSubview(registerButton)
        view.addSubview(cancelButton)
        view.addSubview(activityIndicatorView)
        setupConstraints()
        addGestureRecognizers()
    }
    
    func addBlurEffect() {
        view.backgroundColor = UIColor.clear
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
    }
    
    func addGestureRecognizers() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    @objc func handleImageSelector() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    // Local variable inserted by Swift 4.2 migrator.
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageSelector.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageSelector.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        userNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        passwordVerificationField.resignFirstResponder()
    }
    
    @objc func handleTextChange() {
        let isFormValid = !passwordField.text!.isEmpty && !emailField.text!.isEmpty && !passwordVerificationField.text!.isEmpty && !userNameField.text!.isEmpty
        if isFormValid {
            registerButton.setTitleColor(.white, for: .normal)
            registerButton.isEnabled = true
            registerButton.backgroundColor = UIColor(white: 0.5, alpha: 0.90)
        } else {
            registerButton.setTitleColor(UIColor(white: 0, alpha: 0.3), for: .normal)
            registerButton.isEnabled = false
            registerButton.backgroundColor = UIColor(white: 1, alpha: 0.90)
        }
    }
    
    @objc func handleRegister() {
        guard let email = emailField.text, let password = passwordField.text, let passwordVerification = passwordVerificationField.text, let username = userNameField.text, !email.isEmpty, !password.isEmpty, !passwordVerification.isEmpty, !username.isEmpty else {
            return
        }
        
        if !(passwordVerification.elementsEqual(password)) {
            print("Passwords do not match")
            return
        }
        
        guard let profileImage = imageSelector.imageView?.image else { return }
        
        APIService.shared.registerNewUser(email: email, password: password, username: username, profileImage: profileImage) { (bool) in
            self.activityIndicatorView.stopAnimating()
            if bool {
                print("Dismissing")
                self.dismiss(animated: true) {
                    self.loginController?.dismissController()
                }
                
            } else {
                print("Error Occured")
            }
            
        }

        print("API Called")
        activityIndicatorView.startAnimating()
                
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupConstraints() {

        activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        imageSelector.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageSelector.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        imageSelector.heightAnchor.constraint(equalToConstant: 120).isActive = true
        imageSelector.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
          stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
          stackView.topAnchor.constraint(equalTo: imageSelector.bottomAnchor, constant: 25).isActive = true
          stackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
          stackView.heightAnchor.constraint(equalToConstant: 200).isActive = true

          registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
          registerButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 8).isActive = true
          registerButton.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
          registerButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
          cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
          cancelButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 8).isActive = true
          cancelButton.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
          cancelButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        UIView.animate(withDuration: 0.33, delay: 0, options: .transitionFlipFromBottom, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
      }
}

extension UINavigationController {
   open override var childForStatusBarStyle: UIViewController? {
        return visibleViewController
    }
}
