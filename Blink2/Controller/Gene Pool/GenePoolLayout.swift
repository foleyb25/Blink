//
//  GenePoolLayout.swift
//  Blink2
//
//  Created by Brian Foley on 6/10/20.
//  Copyright © 2020 Brian Foley. All rights reserved.
//

import UIKit

class GenePoolLayout: UICollectionViewFlowLayout {
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)
        layoutAttributes?.forEach({ (attributes) in
            
            guard let collectionView = collectionView else {
                return
            }
            print("Check")
            if attributes.representedElementKind == UICollectionView.elementKindSectionHeader {
                //attributes.frame = CGRect(x: 0, y: 0, width: collectionView.frame.height, height: attributes.frame.width)
                print(attributes.frame)
            }
        })
        
        return layoutAttributes
    }
}

