//
//  SendMessageController.swift
//  Blink
//
//  Created by Brian Foley on 6/18/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit
import Firebase

class SendMessageController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let userCellId = "usercellId"
    var users: [User]? {
        didSet{
            tableView.reloadData()
        }
    }
    
    var image: UIImage?
    var camController: CameraViewController?
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsMultipleSelection = true
        return tableView
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)
        button.addTarget(self, action: #selector(handleSendButton), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.navigationBar.isHidden = false
        tableView.register(UserCell.self, forCellReuseIdentifier: userCellId)
        APIService.shared.fetchUsers { (users) in
            self.users = users
        }
        view.addSubview(tableView)
        view.addSubview(sendButton)
        setupConstraints()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupNavBar()
    }
    
    @objc func handleSendButton() {
        for cellItem in tableView.indexPathsForSelectedRows! {
            if cellItem[1] == 0 {
                //send to gene pool
                guard let gpimage = self.image else { return }
                print("Sending to gene Pool")
                APIService.shared.sendMediaToGenePool(image: gpimage) { (Bool) in
                    self.navigationController?.popToRootViewController(animated: true)
                    self.camController?.lockPreviewMode = false
                }
                
            } else {
                //send to other users
            }
        }
    }
    
    func setupConstraints() {
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        tableView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        tableView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        sendButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -35).isActive = true
        sendButton.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -35).isActive = true
        sendButton.safeAreaLayoutGuide.heightAnchor.constraint(equalToConstant: 44).isActive = true
        sendButton.safeAreaLayoutGuide.widthAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    internal func setupNavBar() {
        self.navigationController?.navigationBar.setBackgroundImage(.none, for: .default)
        self.navigationController?.navigationBar.shadowImage = .none
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = .none
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.item)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print(indexPath.item)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UserCell?
        if indexPath.item == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: userCellId, for: indexPath) as? UserCell
            cell?.textLabel!.text = "Gene Pool"
        } else {
        cell = tableView.dequeueReusableCell(withIdentifier: userCellId, for: indexPath) as? UserCell
            cell!.user = users?[indexPath.item]
        }
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
