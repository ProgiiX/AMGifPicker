//
//  AMGiphyGridLayout.swift
//  GiphyComponent
//
//  Created by Alexander Momotiuk on 11.01.18.
//  Copyright © 2018 Alexander Momotiuk. All rights reserved.
//

import UIKit

protocol AMGiphyGridLayoutDelegate: class {
    
    func numberOfRows(_ collectionView: UICollectionView) -> Int
    func collectionView(_ collectionView: UICollectionView, widthForItemAt indexPath: IndexPath, withHeight height: CGFloat) -> CGFloat
}

class AMGiphyGridLayout: UICollectionViewLayout {
    
    weak var delegate: AMGiphyGridLayoutDelegate?
    
    private var contentHeight: CGFloat {
        return collectionView?.bounds.height ?? 0.0
    }
    private var contentWidth: CGFloat = 0.0
    
    var cache: [UICollectionViewLayoutAttributes] = []
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func prepare() {
        guard let collectionView = collectionView, let delegate = delegate else {
            return
        }
        cache.removeAll()
        
        let numberOfRows = delegate.numberOfRows(collectionView)
        
        let rowHeight = contentHeight / CGFloat(numberOfRows)
        var yOffset = [CGFloat]()
        for column in 0 ..< numberOfRows {
            yOffset.append(CGFloat(column) * rowHeight)
        }
        var column = 0
        var xOffset = [CGFloat](repeating: 0, count: numberOfRows)
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            
            let width = delegate.collectionView(collectionView, widthForItemAt: indexPath, withHeight: rowHeight)
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: width, height: rowHeight)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.append(attributes)
            
            contentWidth = max(contentWidth, frame.maxX)
            xOffset[column] = xOffset[column] + width
            
            column = column < (numberOfRows - 1) ? (column + 1) : 0
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}
