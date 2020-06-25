//
//  APIService.swift
//  Blink
//
//  Created by Brian Foley on 6/18/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import Foundation
import Firebase

class APIService: NSObject {
    static let shared = APIService()
    let imageCache = NSCache<NSString, UIImage>()
    
    func fetchUser(completion: @escaping (User) -> ()) {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                
                let user = User(dictionary: dictionary)
            
                DispatchQueue.main.async {
                    completion(user)
                }
            }) { (err) in
                print("Failed to fetch user:", err)
            }
    }
    
//    func fetchUsers(completion: @escaping ([User]) -> ()) {
//            guard let uid = Auth.auth().currentUser?.uid else { return }
//            
//            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
//                
//                guard let dictionary = snapshot.value as? [String: Any] else { return }
//                
//                let user = User(dictionary: dictionary)
//            
//                DispatchQueue.main.async {
//                    completion(user)
//                }
//
//            }) { (err) in
//                print("Failed to fetch user:", err)
//            }
//    }
    
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
    
    func registerNewUser(email: String, password: String, username: String, profileImage: UIImage, completion: @escaping (Bool) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let err = error {
                print(err)
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            guard let uid = user?.user.uid else { return }
            
            print("Successfully created user: ", uid)
                
            guard let uploadData = profileImage.jpegData(compressionQuality: 0.5) else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return }
            
            let filename = NSUUID().uuidString
            
             let storageRef = Storage.storage().reference().child("profile_images").child(filename)
            storageRef.putData(uploadData, metadata: nil) { (metadata, err) in
                if let err = err {
                    print("Failed to upload profile image:", err)
                    DispatchQueue.main.async {
                        completion(false)
                    }
                    return
                }
                storageRef.downloadURL { (downloadURL, error) in
                    guard let profileImageUrl = downloadURL?.absoluteString else {
                        DispatchQueue.main.async {
                            completion(false)
                        }
                        return
                    }
                    
                     print("Successfully uploaded profile image:", profileImageUrl)
                    
                     let dictionaryValues = ["username": username, "profileimageurl": profileImageUrl]
                     let values = [uid: dictionaryValues]
                    
                    Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
                        
                        if let err = err {
                            print("Failed to save user info into db:", err)
                            DispatchQueue.main.async {
                                completion(false)
                            }
                            return
                        }
                        
                        print("Successfully saved user info to db")
                        DispatchQueue.main.async {
                            completion(true)
                        }
                        
                    })
                }
            }
        }
    }
    
    func signInUser(email: String, password: String, completion: @escaping (Bool) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, err) in
            
            if let err = err {
                print("Failed to sign in with email:", err)
                completion(false)
                return
            }
            
            guard let uid = user?.user.uid else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return }
            
            print("Successfully logged back in with user:", uid)
            DispatchQueue.main.async {
                completion(true)
            }
        })
    }
    
}
