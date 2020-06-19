//
//  SendMessageController.swift
//  Blink
//
//  Created by Brian Foley on 6/18/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit
import Firebase

class SendMessageController: UITableViewController {
    
    let userCellId = "usercellId"
    var users = [User]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        tableView.register(UserCell.self, forCellReuseIdentifier: userCellId)
        
    }
    

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.item)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: userCellId, for: indexPath) as! UserCell
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
