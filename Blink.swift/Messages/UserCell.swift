//
//  UserCell.swift
//  Blink
//
//  Created by Brian Foley on 6/18/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.text = "Barney"
        detailTextLabel?.text = "Barney and friends Incorporated"
        
        setupConstraints()
//        textLabel?.frame = CGRect(x: 70, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height )
//
//        detailTextLabel?.frame = CGRect(x: 70, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height )
    }
    
    let userTextLabel: UILabel = {
       let textLabel = UILabel()
        
        return textLabel
    }()
    
    let userDetailTextLabel: UILabel = {
        let textLabel = UILabel()
        
        return textLabel
    }()
    
    let profileImageThumbnail: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .black
        iv.layer.cornerRadius = 25
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        backgroundColor = .blue
        addSubview(profileImageThumbnail)
        
    }
    
    func setupConstraints() {
        profileImageThumbnail.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        profileImageThumbnail.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageThumbnail.heightAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageThumbnail.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        
        textLabel?.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        textLabel?.leftAnchor.constraint(equalTo: profileImageThumbnail.rightAnchor, constant: 8).isActive = true
        textLabel?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        textLabel?.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        
        detailTextLabel?.translatesAutoresizingMaskIntoConstraints = false
        detailTextLabel?.topAnchor.constraint(equalTo: textLabel!.bottomAnchor, constant: 10).isActive = true
        detailTextLabel?.leftAnchor.constraint(equalTo: profileImageThumbnail.rightAnchor, constant: 8).isActive = true
        detailTextLabel?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        detailTextLabel?.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
