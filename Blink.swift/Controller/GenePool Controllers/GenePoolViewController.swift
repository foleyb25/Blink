//
//  GenePoolViewController.swift
//  Blink2
//
//  Created by Brian Foley on 5/26/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//
//
//
//  TODO: Optimize Database for storing GenePool Media Content
            //Create UML and relational diagram to find the most optimal solution
            //to store and retrieve Gene Pool Content
//  TODO: Store images in DB with lat long coordinates

import UIKit

class GenePoolViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let cellId = "CellId"
    
    let profileViewHeight: CGFloat = 250
    
    lazy var backButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "camera.fill"), for: .normal)
        button.addTarget(self, action: #selector(handleCameraNavButton), for: .touchUpInside)
        return button
    }()
    
    let collection: UICollectionView = {
       let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.bounces = false
        return cv
    }()
    
    let profileView: UIView = {
        let pv = UIView()
        pv.backgroundColor = UIColor.white
        pv.translatesAutoresizingMaskIntoConstraints = false
        return pv
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 130/2
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = label.font.withSize(16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var genderSelector: GenderSelector = {
        let gs = GenderSelector()
        gs.genePoolController = self
        gs.translatesAutoresizingMaskIntoConstraints = false
        return gs
    }()
    
    override func viewDidLoad() {
        setupProfileView()
        setupSelector()
        setupCollectionView()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleDownSwipe))
        swipeDownGestureRecognizer.direction = .down
        view.addGestureRecognizer(swipeDownGestureRecognizer)
        setProfileImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
    }
    
    internal func setupNavBar() {
        //makes nav bar background invisible
        self.navigationController?.navigationBar.setBackgroundImage(.none, for: .default)
        self.navigationController?.navigationBar.shadowImage = .none
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = .none
    }
    
    func setProfileImage() {
        let user = Switcher.shared.currentUser
        guard let url = user?.profileImageURL else { return }
        APIService.shared.fetchImage(urlString: url) { (image: UIImage) in
            self.profileImageView.image = image
        }
        nameLabel.text = Switcher.shared.currentUser?.username
    }
    
    //Fetch new media content from DB here
    @objc func handleDownSwipe() {
        print("swipe down")
    }
    
    @objc func handleCameraNavButton() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func setupCollectionView(){
        view.addSubview(collection)
        collection.dataSource = self
        collection.delegate = self
        collection.register(GPMediaCell.self, forCellWithReuseIdentifier: cellId)
        collection.showsHorizontalScrollIndicator = false
        collection.contentInsetAdjustmentBehavior = .never
        collection.isPagingEnabled = true
        collection.bounces = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.topAnchor.constraint(equalTo: genderSelector.bottomAnchor).isActive = true
        collection.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collection.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        collection.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    }
    
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
    
    //Brings the imageprofile view menu down to orignal state
    func pullDownProfileView() {
        //this kills the scroll, this is needed if user is currently scrolling down while interacting with the gender selector
        imageScrollView?.setContentOffset(imageScrollView!.contentOffset, animated: true)
        profileViewTopAnchor?.constant = 0.0
         UIView.animate(withDuration: 0.5) {
             self.view.layoutIfNeeded()
            
        }
        imageScrollView?.contentOffset.y = 0.0
    }
    
    func scrollToMenuIndex(menuIndex: Int) {
        let indexPath = IndexPath(item: menuIndex, section: 0)
        collection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        pullDownProfileView()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        genderSelector.horizontalSlideBarLeftConstraint?.constant = scrollView.contentOffset.x/2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return 2
       }
       
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! GPMediaCell
           cell.scrollDelegate = self
           return cell
       }
    
    var lastIndex: Int = 0 // keep track of the last index navigated to. init to 0 since index 0 is dequeued initially
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = Int(targetContentOffset.pointee.x / view.frame.width)
        let indexPath = IndexPath(item: index, section: 0)
        
        // switch the gender selector.
        genderSelector.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        
        //Horizontal scrolling ends and the gender selector and profile view are pulled back down as well as the vertical content offset is set to 0. This is a collection view scroll "reset"
        //logic here disables collection view "reset" if the user swipes to horizontally swipe passed the boundary of the collection view. eg. < index 0 or > index 1
        if lastIndex != index {
            pullDownProfileView()
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
    
    // extension variable below. holds a reference to the vertical scroll view in GPMediaCell
    var imageScrollView: UIScrollView?
}

    
/// Extension for GenePoolViewController which implements the scrollDelegate. This recieves data from GPMediaCell and tells this class to increase/decrease the size of the profile view. Additionally, it tells this class to reset the vertical content offset
extension GenePoolViewController: ScrollDelegate {
    func scrollUp(delta: CGFloat, scrollView: UIScrollView) {
        imageScrollView = scrollView
        let contentOffset = scrollView.contentOffset.y
        if contentOffset >= profileViewHeight {return}
        profileViewTopAnchor?.constant = min( (profileViewTopAnchor!.constant - delta) , 0)
    }
    
    func scrollDown(delta: CGFloat, scrollView: UIScrollView) {
        let minimumConstantValue = CGFloat(-self.profileViewHeight)
        imageScrollView = scrollView
        profileViewTopAnchor?.constant = max(minimumConstantValue, (profileViewTopAnchor!.constant - delta))
    }
    

}
