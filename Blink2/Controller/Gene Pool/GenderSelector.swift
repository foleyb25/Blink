//
//  GenderSelector.swift
//  Blink2
//
//  Created by Brian Foley on 5/26/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

protocol MenuDelegate: AnyObject {
    func switchCollectionView()
}

class GenderSelector: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let genders = ["chicks","dudes"]
    
    lazy var collectionView: UICollectionView = {
       let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        //collectionView.register(SelectionCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.backgroundColor = UIColor.red
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        collectionView.register(SelectionCell.self, forCellWithReuseIdentifier: cellId)
        addSubview(collectionView)
        addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        addConstraintsWithFormat("V:|[v0]|", views: collectionView)
        
        let selectedIndexPath = NSIndexPath(item: 0, section: 0)
        collectionView.selectItem(at: selectedIndexPath as IndexPath, animated: false, scrollPosition: .bottom)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let cellId = "cellId"
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SelectionCell
        cell.label.text = genders[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width / 2, height: frame.height)
    }
    
}

class SelectionCell: BaseCell {
    
    var label: UILabel = {
            let label = UILabel()
            label.text = "chick"
            label.backgroundColor = UIColor.clear
        label.textAlignment = .center
            return label
    }()
    
//    override var isHighlighted: Bool {
//        didSet {
//            backgroundColor = UIColor.lightGray
//        }
//    }
    
    override var isSelected: Bool {
           didSet {
            backgroundColor = isSelected ? UIColor.lightGray : UIColor.clear
           }
       }
    
    override func setupViews() {
        super.setupViews()
        backgroundColor = UIColor.red
        addSubview(label)
        addConstraintsWithFormat("H:[v0(100)]", views: label)
        addConstraintsWithFormat("V:|[v0]|", views: label)
        addConstraint(NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
    }
    
}
