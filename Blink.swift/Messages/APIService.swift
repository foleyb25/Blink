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
    
    
       func fetchUsers(completion: @escaping ([User]) -> ()) {
            Database.database().reference().child("users").observe( .childAdded, with: { (snapshot) in
                
                print(snapshot)
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    var users = [User]()
                    let user = User(dictionary: dictionary)
                    users.append(user)
                    //user.setValuesForKeys(dictionary)
                    
                    
                    DispatchQueue.main.async {
                        completion(users)
                    }
                }
            }, withCancel: nil)
        }
        
//        func fetchFeedForUrlString(urlString: String, completion: @escaping ([User]) -> ()) {
//            let url = URL(string: urlString)
//            URLSession.shared.dataTask(with: url!) { (data, response, error) in
//                
//                if error != nil {
//                    print(error ?? "")
//                    return
//                }
//                
//                do {
//                    guard let data = data else { return }
//                    let decoder = JSONDecoder()
//                    decoder.keyDecodingStrategy = .convertFromSnakeCase
//                    let videos = try decoder.decode([Video].self, from: data)
//                    
//                    DispatchQueue.main.async {
//                        completion(videos)
//                    }
//                    
//                } catch let jsonError {
//                    print(jsonError)
//                }
//                
//                
//                
//                }.resume()
//        }
}
