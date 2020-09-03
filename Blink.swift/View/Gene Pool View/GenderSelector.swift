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
    
    var genePoolController: GenePoolViewController?
    let genders = ["Chicks","Dudes"]
    
    lazy var collectionView: UICollectionView = {
       let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(white: 0.75, alpha: 1)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    let horizontalSlideBar: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor(white: 0.35, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let horizontalSeperator: UIView = {
       let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var horizontalSlideBarLeftConstraint: NSLayoutConstraint?
    
    fileprivate func setupCollectionView() {
        collectionView.register(SelectionCell.self, forCellWithReuseIdentifier: cellId)
        addSubview(collectionView)
        addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        addConstraintsWithFormat("V:|[v0]|", views: collectionView)
        let selectedIndexPath = NSIndexPath(item: 0, section: 0)
        collectionView.selectItem(at: selectedIndexPath as IndexPath, animated: false, scrollPosition: .bottom)
    }
    
    fileprivate func setupHorizontalSlideBar() {
        addSubview(horizontalSlideBar)
        horizontalSlideBarLeftConstraint = horizontalSlideBar.leftAnchor.constraint(equalTo: leftAnchor)
        horizontalSlideBarLeftConstraint?.isActive = true
        horizontalSlideBar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        horizontalSlideBar.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/2).isActive = true
        horizontalSlideBar.heightAnchor.constraint(equalToConstant: 4).isActive = true
    }
    
    fileprivate func setupHorizontalBar() {
        addSubview(horizontalSeperator)
        horizontalSeperator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        horizontalSeperator.bottomAnchor.constraint(equalTo: topAnchor).isActive = true
        horizontalSeperator.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        horizontalSeperator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
        setupHorizontalSlideBar()
        setupHorizontalBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    let cellId = "cellId"
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            genePoolController?.scrollToMenuIndex(menuIndex: indexPath.item)
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
        label.textAlignment = .center
        return label
    }()
    
    override var isSelected: Bool {
           didSet {
            backgroundColor = isSelected ? UIColor(white: 1, alpha: 1) : UIColor.clear
            label.textColor = isSelected ? UIColor(white: 0, alpha: 1) : UIColor(white: 0.5, alpha: 1)
           }
       }
    
    override func setupViews() {
        super.setupViews()
        addSubview(label)
        addConstraintsWithFormat("H:[v0(100)]", views: label)
        addConstraintsWithFormat("V:|[v0]|", views: label)
        addConstraint(NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
    }
    
}
