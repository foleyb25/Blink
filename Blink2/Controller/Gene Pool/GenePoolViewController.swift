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
    
    let profileViewHeight: CGFloat = 400
    
    override func viewDidLoad() {
        setupProfileView()
        setupSelector()
        setupCollectionView()
        
    }
    
    func setupCollectionView(){
        collectionView.backgroundColor = UIColor.white
        collectionView.register(ImageCells.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentLayoutGuide.topAnchor.constraint(equalTo: genderSelector.bottomAnchor).isActive = true
        
        collectionView.contentLayoutGuide.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive=true
        collectionView.contentLayoutGuide.heightAnchor.constraint(equalTo: view.heightAnchor).isActive=true
        collectionView.contentLayoutGuide.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
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
        profileView.heightAnchor.constraint(equalToConstant: profileViewHeight).isActive = true
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
           return 2
       }
       
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ImageCells
           cell.scrollDelegate = self
           return cell
       }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = Int(targetContentOffset.pointee.x / view.frame.width)
        let indexPath = IndexPath(item: index, section: 0)
        genderSelector.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        profileViewTopAnchor?.isActive = false
        profileViewTopAnchor = profileView.topAnchor.constraint(equalTo: view.topAnchor)
        profileViewTopAnchor?.isActive = true
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }

     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

extension GenePoolViewController: ScrollDelegate {
    func scrollUp(delta: CGFloat) {
        profileViewTopAnchor?.constant = min(profileViewTopAnchor!.constant - delta, 0)
    }
    
    func scrollDown(delta: CGFloat) {
        let minimumConstantValue = CGFloat(-300)
        profileViewTopAnchor?.constant = max(minimumConstantValue, profileViewTopAnchor!.constant - delta)
    }
    

}
