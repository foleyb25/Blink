//
//  HeaderView.swift
//  Blink2
//
//  Created by Brian Foley on 6/10/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

class FooterView: UICollectionViewCell {
    
    let safeAreaBottom = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
    
    lazy var showMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show More", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleShowMore), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addSubview(showMoreButton)
        showMoreButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        showMoreButton.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        showMoreButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        showMoreButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("Fatal Error")
    }
    
    @objc func handleShowMore() {
        print("Show More")
    }
}
