//
//  Switcher.swift
//  Blink
//
//  Created by Brian Foley on 6/16/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit
import Firebase

class Switcher {
    
    static let shared = Switcher()
    var rootVC: UIViewController?
    
    // only set root vc when user has been set. creates navigation bugs if not set
    var currentUser: User? {
        didSet {
           rootVC = self.cameraNavController
           setRootVC()
        }
    }
    
    lazy var cameraNavController: UINavigationController = {
        let camVc = CameraViewController()
        let navController = UINavigationController(rootViewController: camVc)
        return navController
    }()
    
    lazy var loginNavController: UINavigationController = {
        let loginVc = LoginViewController()
        let navController = UINavigationController(rootViewController: loginVc)
        return navController
    }()
    
    
    /// This function updates the Root View Controller with the current User.
    ///
    /// ```
    /// Need to optimize the duration of presenting the rootVC. Start with database retrieval as the first point of optimization
    /// ```
    ///
    /// - Warning: The updated root controller may take awhile since the rootVC doesnt get set until DB retrieval has been made
    /// - Parameter None
    /// - Returns: None
    func updateRootVC() {
          
           if(Auth.auth().currentUser != nil) {
                rootVC = nil
                APIService.shared.fetchUser { (user: User) in
                    self.currentUser = user
                }
           } else {
                currentUser = nil
                rootVC = nil
                rootVC = self.loginNavController
                setRootVC()
           }
    }
    
    private func setRootVC() {
        if #available(iOS 13.0, *) {
             UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
         UIApplication.shared.windows.first?.rootViewController = rootVC
        } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
         appDelegate.window?.rootViewController?.dismiss(animated: true, completion: nil)
         appDelegate.window?.rootViewController = rootVC
        }
    }
    
    func updateUserInfowith(genderId: String?, didRegisterGP: Bool?) {
        if let gid = genderId {
            currentUser?.genderId = gid
        }
        
        if let didRegister = didRegisterGP {
            currentUser?.didRegisterGP = didRegister
        }
    }
}
