//
//  Switcher.swift
//  Blink
//
//  Created by Brian Foley on 6/16/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

// TODO: - Optimize DB Retrieval and presentation of VC's
// TODO: - Minimize Memory Leaks

import UIKit
import Firebase

/**
 This class is responsible for updating the root view controller and obtaining the signed in user's data. Data in this class is intended to be accessible to all other classes.
*/
class Switcher {
    static let shared = Switcher()
    var rootVC: UIViewController?
    
    // only set root vc when user has been set. creates navigation bugs if not set
    var currentUser: User? {
        didSet {
           
        }
    }
    
    var settings: Settings?
    
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
    
    /**
     This function updates the Root View Controller with the current User.
    
     ## Notes
     Need to optimize the duration of presenting the rootVC. Start with database retrieval as the first point of optimization
   
     - Warning: The updated root controller may take awhile since the rootVC doesnt get set until DB retrieval has been made
     - Parameter None
     - Returns: None
     
     ## Called In
     - LoginViewController.swift
     - SettingsController.swift
     - CameraViewController.swift
     - AppDelegate.swift
     - SceneDelegate.swift
    */
    func updateRootVC() {
    
        if(Auth.auth().currentUser != nil) {
            rootVC = nil
            APIService.shared.fetchUser { (user) in
                self.currentUser = user
                
            }
            
            APIService.shared.fetchUserSettings { (settings) in
                self.settings = settings
                
            }
            
            rootVC = self.cameraNavController
            setRootVC()
       } else {
            currentUser = nil
            rootVC = nil
            rootVC = self.loginNavController
            setRootVC()
       }
    }
    
    /**
     Helper function to updateRootVC.
    
    ## Notes
     Depending on the version of IOS being run, the root view controller is set to the application window. Since this is a single window app, discovering multiple windows is not necessary
    
     - Warning: None
     - Parameter None
     - Returns: None
    */
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
    
    /**
     Updates current user's info if the user updates his/her information when browsing the app
    
     ## Notes
     If a user updates their information, the current user's data in this class is updated. If not, this creates conflicts when attempting to display data or access parts of the app. This method updates the current users information specifically if the user has registered for the Gene Pool and fixes the problem.
    
     - Warning: None
     - Parameter None
     - Returns: None
     
     ## Called in
     - APIService.swift
    */
    func updateUserInfowith(genderId: String?, didRegisterGP: Bool?) {
        if let gid = genderId {
            settings?.genderId = gid
        }
    }
    
}
