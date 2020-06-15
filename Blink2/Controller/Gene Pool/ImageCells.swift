//
//  ImageCells.swift
//  Blink2
//
//  Created by Brian Foley on 5/26/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

protocol ScrollDelegate: AnyObject {
    func scrollUp(delta: CGFloat)
    func scrollDown(delta: CGFloat)
}

class ImageCells: BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
     weak var scrollDelegate: ScrollDelegate?
    
    let chickCellId = "chickCellId"
    
    let imageCollection: UICollectionView = {
       let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.bounces = false
        return cv
    }()
    
    override func setupViews() {
        super.setupViews()
        imageCollection.dataSource = self
        imageCollection.delegate = self
        imageCollection.register(ChickCell.self, forCellWithReuseIdentifier: chickCellId)
        addSubview(imageCollection)
        
        addConstraintsWithFormat("H:|[v0]|", views: imageCollection)
        addConstraintsWithFormat("V:|[v0]|", views: imageCollection)
        imageCollection.contentInset = UIEdgeInsets(top: 360, left: 1, bottom: 0, right: 1)
        imageCollection.scrollIndicatorInsets = UIEdgeInsets(top: 360, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: chickCellId, for: indexPath) as! ChickCell
    }
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: imageCollection.frame.width/2 - 2, height: 200)
       }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        1
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        print("Scrolled to top")
    }
    
    var lastContentOffset: CGFloat?

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
        let scrollViewHeight = scrollView.frame.height
        let scrollContentSizeHeight = scrollView.contentSize.height
        let scrollOffset = scrollView.contentOffset.y
        
    
        
        if (scrollOffset <= -448.0) {
            //reached top
            return
        } else if (scrollOffset+scrollViewHeight >= scrollContentSizeHeight) {
            //reached bottom
            return
        } else {
        
        
        if let lastOffset = lastContentOffset {
            
            let delta = scrollOffset - lastOffset
            if delta < 0 {
               scrollDelegate?.scrollUp(delta: delta)
            } else {
                scrollDelegate?.scrollDown(delta: delta)
            }
        }
        lastContentOffset = scrollView.contentOffset.y
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastContentOffset = scrollView.contentOffset.y
    }
    
    
}



class ChickCell: BaseCell {
    
    override func setupViews() {
        super.setupViews()
        backgroundColor = .red
    }
}

class DudeCell: BaseCell {
    
    override func setupViews() {
        super.setupViews()
        backgroundColor = .red
    }
}
