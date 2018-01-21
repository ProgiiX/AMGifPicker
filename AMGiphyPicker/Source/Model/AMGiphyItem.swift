//
//  AMGiphyItem.swift
//  GiphyComponent
//
//  Created by Alexander Momotiuk on 11.01.18.
//  Copyright © 2018 Alexander Momotiuk. All rights reserved.
//

import UIKit

class AMGiphyItem {
    
    let id: String
    let thumbnailUrl: String?
    let gifUrl: String?
    let size: CGSize
    
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
