//
//  SideBarMenuViewController.swift
//  Blink2
//
//  Created by Brian Foley on 5/20/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//



import UIKit

class SideBarMenuController: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    lazy var blackView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        let swipeLeftGesturebv = UISwipeGestureRecognizer(target: self, action: #selector(handleDismiss))
        swipeLeftGesturebv.direction = .left
        view.addGestureRecognizer(swipeLeftGesturebv)
        return view
    }()
    
    let profileView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        let swipeLeftGesturecv = UISwipeGestureRecognizer(target: self, action: #selector(handleDismiss))
        swipeLeftGesturecv.direction = .left
        cv.addGestureRecognizer(swipeLeftGesturecv)
        return cv
    }()
    
    override init() {
        super.init()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SideBarCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    func showSideMenu() {
        //show menu

        if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            
            window.addSubview(blackView)
            window.addSubview(collectionView)
            
            // if Camera is recording put a red pulse animation over black layer
            if cameraViewController!.isRecording {
                Animations.animatePulsatingLayer(layer: blackView.layer)
            }
            
            collectionView.frame = CGRect(x: -window.frame.width, y: 0, width: window.frame.width/2, height: window.frame.height)
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            //self.collectionView.addSubview(profileView)
            //setupConstraints()
            
            UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackView.alpha = 1
                
                self.collectionView.frame = CGRect(x: 0, y: 0, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                
               
            }, completion: nil)
        }
    }
    
    func setupConstraints() {
//        let profileViewHeight: CGFloat = 100.0
//        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
//        profileView.topAnchor.constraint(equalTo: collectionView.topAnchor).isActive = true
//        profileView.heightAnchor.constraint(equalToConstant: 100).isActive = true
//        profileView.widthAnchor.constraint(equalTo: collectionView.widthAnchor).isActive = true
//        profileView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor).isActive = true
//
    }
    
    @objc func handleDismiss() {
        blackView.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.50) {
            self.blackView.alpha = 0
            if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
                self.collectionView.frame = CGRect(x: -window.frame.width, y: 0, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }
        }
    }
    
    let cellId = "cellid"
    
    private lazy var cellItems: [SideBarCellItem] = {
        return [SideBarCellItem(name: "Profile", imageName: "person.fill"), SideBarCellItem(name: "Showcase", imageName: "star.fill"), SideBarCellItem(name: "Friends", imageName: "person.3.fill"), SideBarCellItem(name: "Connections", imageName: "shuffle"),  SideBarCellItem(name: "Settings", imageName: "gear")]
    }()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SideBarCell
        let cellItem = cellItems[indexPath.item]
        cell.cellItem = cellItem
        return cell
    }
    
    weak var cameraViewController: CameraViewController?
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleDismiss()
        guard let camViewController = cameraViewController else {
            return
        }
        if camViewController.isRecording {
            print("Cant transition recording in process")
            return
        }

        var controller: UIViewController?
        
        switch cellItems[indexPath.item].name {
        case "Profile":
            controller = ProfileController()
            break
        case "Showcase":
            controller = ShowcaseController()
            break
        case "Friends":
            controller = FriendsController()
            break
        case "Connections":
            controller = ConnectionsController()
            break
        case "Settings":
            controller = SettingsController()
            break
        default:
            print("Could not find selected path")
        }
        guard let controllerToPresent = controller else { return }
        
        camViewController.present(controllerToPresent, animated: true, completion: nil)
    }
}


