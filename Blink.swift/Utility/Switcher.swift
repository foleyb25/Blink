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
    
    func updateRootVC() {
          
           if(Auth.auth().currentUser != nil) {
               
                rootVC = self.cameraNavController

           } else {
                rootVC = self.loginNavController
           }
           
           if #available(iOS 13.0, *) {
                UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
            UIApplication.shared.windows.first?.rootViewController = rootVC
           } else {
               let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController?.dismiss(animated: true, completion: nil)
            appDelegate.window?.rootViewController = rootVC
           }
       }
}
