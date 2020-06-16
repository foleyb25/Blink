//
//  ImageCells.swift
//  Blink2
//
//  Created by Brian Foley on 5/26/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

protocol ScrollDelegate: AnyObject {
    func scrollUp(delta: CGFloat, scrollView: UIScrollView)
    func scrollDown(delta: CGFloat, scrollView :UIScrollView)
}

class ImageCells: BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
     weak var scrollDelegate: ScrollDelegate?
    
    let chickCellId = "chickCellId"
    let footerId = "FooterId"
    
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
        imageCollection.register(FooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerId)
        addConstraintsWithFormat("H:|[v0]|", views: imageCollection)
        addConstraintsWithFormat("V:|[v0]|", views: imageCollection)
        //imageCollection.contentInset = UIEdgeInsets(top: 1, left: 1, bottom: 400, right: 1)
        imageCollection.scrollIndicatorInsets = UIEdgeInsets(top: 1, left: 1, bottom: 0, right: 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerId, for: indexPath) as! FooterView

        return footer
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: frame.width, height: 175)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 1, bottom: 0, right: 1)
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        print("Scrolled to top")
    }
    
    var lastContentOffset: CGFloat?

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
        let scrollOffset = scrollView.contentOffset.y
        
        if let lastOffset = lastContentOffset {
            
            let delta = scrollOffset - lastOffset
            if delta < 0 {
               
                scrollDelegate?.scrollUp(delta: delta, scrollView: scrollView)
            } else {
                scrollDelegate?.scrollDown(delta: delta, scrollView: scrollView)
            }
        }
        lastContentOffset = scrollView.contentOffset.y
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
