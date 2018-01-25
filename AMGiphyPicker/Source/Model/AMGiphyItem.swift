//
//  AMGiphyItem.swift
//  GiphyComponent
//
//  Created by Alexander Momotiuk on 11.01.18.
//  Copyright © 2018 Alexander Momotiuk. All rights reserved.
//

import UIKit
import GiphyCoreSDK

fileprivate struct Constants {
    static let defaultHeight = 100
    static let defaultWidth = 100
}

class AMGiphyItem {
    
    let id: String
    let thumbnailUrl: String?
    let gifUrl: String?
    let size: CGSize
    
    init(_ giphy: GPHMedia) {
        self.id = giphy.id
        self.thumbnailUrl = giphy.images?.fixedHeightSmallStill?.gifUrl ?? giphy.images?.fixedWidthSmallStill?.gifUrl
        self.gifUrl = giphy.images?.fixedHeightSmall?.gifUrl ?? giphy.images?.fixedWidthSmall?.gifUrl
        
        let width = giphy.images?.fixedHeightSmall?.width ?? giphy.images?.fixedWidthSmall?.width ?? Constants.defaultWidth
        let height = giphy.images?.fixedHeightSmall?.height ?? giphy.images?.fixedWidthSmall?.height ?? Constants.defaultHeight
        self.size = CGSize(width: width, height: height)
    }
    
    init(_ id: String, thumbnail: String?, gif: String?, size: CGSize) {
        self.id = id
        self.thumbnailUrl = thumbnail
        self.gifUrl = gif
        self.size = size
    }
}

extension AMGiphyItem: Hashable {
    
    var hashValue: Int {
        return id.hashValue
    }
}

extension AMGiphyItem: Equatable {
    
    static func ==(lhs: AMGiphyItem, rhs: AMGiphyItem) -> Bool {
        return lhs.id == rhs.id
    }
}
