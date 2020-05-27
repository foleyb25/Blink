//
//  GenePoolViewController.swift
//  Blink2
//
//  Created by Brian Foley on 5/26/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

class GenePoolViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "CellId"
    
    override func viewDidLoad() {
        setupProfileView()
        setupSelector()
        setupCollectionView()
    }
    
    func setupCollectionView(){
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ImageCells.self, forCellWithReuseIdentifier: cellId)
        collectionView?.contentInset = UIEdgeInsets(top: 370, left: 5, bottom: 0, right: 5)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 370, left: 0, bottom: 0, right: 0)
        collectionView?.bounces = false
        print(profileView.frame.height)
        print(genderSelector.frame.height)
    }
    
    let profileView: UIView = {
        let pv = UIView()
        pv.backgroundColor = UIColor.white
        pv.translatesAutoresizingMaskIntoConstraints = false
        return pv
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "barney")
        imageView.image = image
        imageView.backgroundColor = UIColor.red
        imageView.layer.cornerRadius = 60
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Barney"
        label.textAlignment = .center
        label.font = label.font.withSize(16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let genderSelector: GenderSelector = {
        let gs = GenderSelector()
        gs.translatesAutoresizingMaskIntoConstraints = false
        return gs
    }()
    
    func setupSelector() {
        view.addSubview(genderSelector)
        view.addConstraintsWithFormat("H:|[v0]|", views: genderSelector)
        genderSelector.topAnchor.constraint(equalTo: profileView.bottomAnchor).isActive = true
        genderSelector.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
    }
    
    var profileViewHeightAnchor: NSLayoutConstraint?
    var profileViewTopAnchor: NSLayoutConstraint?
    
    func setupProfileView() {
        view.addSubview(profileView)
        profileView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        profileViewTopAnchor = profileView.topAnchor.constraint(equalTo: view.topAnchor)
        profileViewTopAnchor?.isActive = true
        profileView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        profileView.addSubview(profileImageView)
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: profileView.centerYAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 130).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 130).isActive = true
        profileView.addSubview(nameLabel)
        nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 25).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        nameLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return 10
       }
       
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ImageCells
           return cell
       }
    
   
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           let height = (view.frame.width - 16 - 16) * 9 / 16
           return CGSize(width: view.frame.width/2 - 7, height: height + 16 + 88)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let lastOffset = lastContentOffset {
            
            let delta = scrollView.contentOffset.y - lastOffset
            let minimumConstantValue = CGFloat(-300)
            print(lastOffset)
            //print(delta)
            //let range: Range<CGFloat> = (-400..<0)
            if delta < 0 {
                   //scrolling up
                profileViewTopAnchor?.constant = min(profileViewTopAnchor!.constant - delta, 0)
            } else {
                   //scrolling down
                profileViewTopAnchor?.constant = max(minimumConstantValue, profileViewTopAnchor!.constant - delta)
            }
        }
        lastContentOffset = scrollView.contentOffset.y
    }
    
    var lastContentOffset: CGFloat?
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastContentOffset = scrollView.contentOffset.y
    }
    
}
