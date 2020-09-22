//
//  HeaderView.swift
//  Blink2
//
//  Created by Brian Foley on 6/10/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//
/// This class represents the footer view in the gene pool. It consists of a button that will show more Gene Pool media content from 25 images/videos to an additional 25.

import UIKit

class FooterView: UICollectionViewCell {
    
    lazy var showMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show More", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleShowMore), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .blue
        addSubview(showMoreButton)
        showMoreButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        showMoreButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
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
