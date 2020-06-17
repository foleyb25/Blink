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
    
     static func updateRootVC() {
           //let status = UserDefaults.standard.bool(forKey: "status")
           var rootVC : UIViewController?
          
           if(Auth.auth().currentUser != nil) {
               
               rootVC = CameraViewController()
               
               //rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Container") as! Container
               
           } else {
               rootVC = LoginViewController()
           }
           
        UIApplication.shared.keyWindow?.rootViewController = UINavigationController(rootViewController: rootVC!)
           //if #available(iOS 13.0, *) {
//            let sceneDelegate = UIApplication.shared.delegate as! SceneDelegate
//                sceneDelegate.window?.rootViewController = UINavigationController(rootViewController: rootVC!)
//                sceneDelegate.window?.makeKeyAndVisible()
//           } else {
//
//        UIApplication.shared
//               let appDelegate = UIApplication.shared.delegate as! AppDelegate
//               appDelegate.window?.rootViewController = UINavigationController(rootViewController: rootVC!)
//               appDelegate.window?.makeKeyAndVisible()
//           }
       }
}
