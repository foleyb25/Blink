//
//  APIService.swift
//  Blink
//
//  Created by Brian Foley on 6/18/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import Foundation
import Firebase

class APIService: UIViewController {
    static let shared = APIService()
    let imageCache = NSCache<NSString, UIImage>()
    
       func fetchUser(completion: @escaping (User) -> ()) {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                //print(snapshot.value ?? "")
                
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                
                let user = User(dictionary: dictionary)
            
                DispatchQueue.main.async {
                    completion(user)
                }
            }) { (err) in
                print("Failed to fetch user:", err)
            }
        }
    
    func fetchProfilePictureWithUrl(urlString: String, completion: @escaping (UIImage) -> ()) {
            
            if let imageFromCache = imageCache.object(forKey: urlString as NSString) {
                return completion(imageFromCache)
            }
            
            print("Loading image...")
            guard let url = URL(string: urlString) else { return }
            
            URLSession.shared.dataTask(with: url) { (data, response, err) in
                if let err = err {
                    print("Failed to fetch post image:", err)
                    return
                }
                guard let imageData = data else { return }
                
                guard let photoImage = UIImage(data: imageData) else { return }
                
                DispatchQueue.main.async {
                    self.imageCache.setObject(photoImage, forKey: urlString as NSString)
                    completion(photoImage)
                }
                
                }.resume()
        }
}
