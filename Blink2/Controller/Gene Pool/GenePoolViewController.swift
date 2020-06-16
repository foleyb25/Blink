//
//  GenePoolViewController.swift
//  Blink2
//
//  Created by Brian Foley on 5/26/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit



class GenePoolViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
   
    
    let cellId = "CellId"
    
    
    let profileViewHeight: CGFloat = 250
    
    override func viewDidLoad() {
        setupProfileView()
        setupSelector()
        setupCollectionView()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Camera Button", style: .plain, target: self, action: #selector(handleCameraNavButton))
    }
    
    let collection: UICollectionView = {
       let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.bounces = false
        return cv
    }()
    
    @objc func handleCameraNavButton() {
        dismiss(animated: true, completion: nil)
    }
    func setupCollectionView(){
        view.insertSubview(collection, at: 0)
        collection.dataSource = self
        collection.delegate = self
        collection.backgroundColor = UIColor.white
        collection.register(ImageCells.self, forCellWithReuseIdentifier: cellId)
        collection.showsHorizontalScrollIndicator = false
        collection.contentInsetAdjustmentBehavior = .never
        collection.isPagingEnabled = true
        collection.bounces = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.topAnchor.constraint(equalTo: genderSelector.bottomAnchor).isActive = true
        collection.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collection.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        //collection.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collection.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
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
        profileViewTopAnchor = profileView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        profileViewTopAnchor?.isActive = true
        profileView.heightAnchor.constraint(equalToConstant: profileViewHeight).isActive = true
        profileView.addSubview(profileImageView)
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: profileView.topAnchor, constant: 25).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 130).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 130).isActive = true
        profileView.addSubview(nameLabel)
        nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 25).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        nameLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return 2
       }
       
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ImageCells
           cell.scrollDelegate = self
           return cell
       }
    
    var lastIndex: Int = 0
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = Int(targetContentOffset.pointee.x / view.frame.width)
        let indexPath = IndexPath(item: index, section: 0)
        genderSelector.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        if lastIndex != index {
            profileViewTopAnchor?.constant = 0.0
             UIView.animate(withDuration: 0.5) {
                 self.view.layoutIfNeeded()
                
        }
            imageScrollView?.contentOffset.y = 0.0
            lastIndex = index
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
    var imageScrollView: UIScrollView?
}

    

extension GenePoolViewController: ScrollDelegate {
    func scrollUp(delta: CGFloat, scrollView: UIScrollView) {
        imageScrollView = scrollView
        profileViewTopAnchor?.constant = min( (profileViewTopAnchor!.constant - delta) , 0)
    }
    
    func scrollDown(delta: CGFloat, scrollView: UIScrollView) {
        let minimumConstantValue = CGFloat(-self.profileViewHeight)
        imageScrollView = scrollView
        profileViewTopAnchor?.constant = max(minimumConstantValue, (profileViewTopAnchor!.constant - delta))
    }
    

}
