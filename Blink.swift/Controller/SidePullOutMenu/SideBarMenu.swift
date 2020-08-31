//
//  SideBarMenuViewController.swift
//  Blink2
//
//  Created by Brian Foley on 5/20/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

class SideBarMenu: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    lazy var blackView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        let swipeLeftGesturebv = UISwipeGestureRecognizer(target: self, action: #selector(handleDismiss))
        swipeLeftGesturebv.direction = .left
        view.addGestureRecognizer(swipeLeftGesturebv)
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
            
            UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackView.alpha = 1
                
                self.collectionView.frame = CGRect(x: 0, y: 0, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                
            }, completion: nil)
        }
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
    
    private lazy var cellItems: [CellItem] = {
        return [CellItem(name: "Profile", imageName: "logo_no_bg", controller: Profile()), CellItem(name: "Settings", imageName: "logo_no_bg", controller: Settings())]
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
        let controller = cellItems[indexPath.item].controller
        camViewController.present(controller, animated: true, completion: nil)
    }
    
}

class CellItem: NSObject {
    let name: String
    let imageName: String
    let controller: UIViewController
    
    init(name: String, imageName: String, controller: UIViewController) {
        self.name = name
        self.imageName = imageName
        self.controller = controller
    }
}

class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init has not been implemented")
    }
}
