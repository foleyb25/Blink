//
//  GenePoolRegisterController.swift
//  Blink
//
//  Created by Brian Foley on 6/25/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//
//  If user has not yet registered info for the gene pool, present this screen

import UIKit

class GenePoolRegisterController: UIViewController {
    
    enum Gender: Int {
        case chick = 0
        case dude = 1
    }
    
    var cameraViewController: CameraViewController?
    
    let stackView: UIStackView = {
       let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.distribution = .fillEqually
        sv.axis = .horizontal
        sv.spacing = 10
        sv.backgroundColor = .white
        return sv
    }()
    
    let chickButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Chick", for: .normal)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor(white: 0.5, alpha: 0.5).cgColor
        button.layer.cornerRadius = 8
        button.tag = Gender.chick.rawValue
        button.addTarget(self, action: #selector(handleButtonPress(sender:)), for: .touchUpInside)
        button.layer.masksToBounds = true
        return button
    }()
    
    let dudeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Dude", for: .normal)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor(white: 0.5, alpha: 0.5).cgColor
        button.layer.cornerRadius = 8
        button.tag = Gender.dude.rawValue
        button.addTarget(self, action: #selector(handleButtonPress(sender:)), for: .touchUpInside)
        return button
    }()
    
    let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.layer.backgroundColor = UIColor(white: 0, alpha: 0.85).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleSubmitButton), for: .touchUpInside)
        return button
    }()
    
    var selectedValue: Int?
    
    @objc func handleSubmitButton() {
        guard let selectedVal = selectedValue else {
            print("value not selected")
            return
        }
        if selectedVal == Gender.chick.rawValue {
            APIService.shared.updateDBwith(genderId: "chick") { (bool) in
                if bool {
                self.navigationController?.pushViewController(self.cameraViewController!.genePoolController, animated: true)
                } else {
                    print("Error updating DB")
                }
            }
        } else if selectedVal == Gender.dude.rawValue {
            APIService.shared.updateDBwith(genderId: "dude") { (bool) in
                if bool {
                self.navigationController?.pushViewController(self.cameraViewController!.genePoolController, animated: true)
                } else {
                    print("Error updating DB")
                }
            }
        } else {
            print("unknown value")
        }
    }
    
    @objc func handleButtonPress(sender: UIButton) {
        switch(sender.tag) {
        case Gender.chick.rawValue:
            selectedValue = Gender.chick.rawValue
            UIView.animate(withDuration: 0.25) {
                self.chickButton.layer.backgroundColor = UIColor(white: 0, alpha: 0.75).cgColor
                self.dudeButton.layer.backgroundColor = UIColor(white: 1, alpha: 0).cgColor
            }
            break
        case Gender.dude.rawValue:
            selectedValue = Gender.dude.rawValue
            UIView.animate(withDuration: 0.25) {
                self.dudeButton.layer.backgroundColor = UIColor(white: 0, alpha: 0.75).cgColor
                self.chickButton.layer.backgroundColor = UIColor(white: 1, alpha: 0).cgColor
            }
            break
        default:
            print("?? value")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(stackView)
        view.addSubview(submitButton)
        stackView.addArrangedSubview(chickButton)
        stackView.addArrangedSubview(dudeButton)
        view.backgroundColor = .white
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
    }
    
    internal func setupNavBar() {
        //makes nav bar background invisible
        self.navigationController?.navigationBar.setBackgroundImage(.none, for: .default)
        self.navigationController?.navigationBar.shadowImage = .none
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = .none
    }
    
    fileprivate func setupConstraints() {
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        stackView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        submitButton.leftAnchor.constraint(equalTo: stackView.leftAnchor).isActive = true
        submitButton.rightAnchor.constraint(equalTo: stackView.rightAnchor).isActive = true
        submitButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 25).isActive = true
        submitButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}
