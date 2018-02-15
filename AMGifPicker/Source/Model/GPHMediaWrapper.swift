//
//  GPHMediaWrapper.swift
//  AMGifPicker
//
//  Created by Alexander Momotiuk on 2/15/18.
//  Copyright © 2018 Alexander Momotiuk. All rights reserved.
//

import Foundation
import GiphyCoreSDK

fileprivate struct Constants {
    static let defaultHeight = 100
    static let defaultWidth = 100
}


extension GPHMedia: AMGifWrapper {
    
    var key: String {
        return id
    }
    
    var thumbnailUrl: String {
        if let url = images?.fixedHeightSmallStill?.gifUrl, url.count > 0 {
            return url
        }
        if let url = images?.fixedWidthSmallStill?.gifUrl, url.count > 0 {
            return url
        }
        if let url = images?.fixedHeightStill?.gifUrl, url.count > 0 {
            return url
        }
        if let url = images?.fixedWidthStill?.gifUrl, url.count > 0 {
            return url
        }
        return images?.originalStill?.gifUrl ?? ""
    }
    
    var gifUrl: String {
        if let url = images?.fixedHeightSmall?.gifUrl, url.count > 0 {
            return url
        }
        if let url = images?.fixedWidthSmall?.gifUrl, url.count > 0 {
            return url
        }
        if let url = images?.fixedHeight?.gifUrl, url.count > 0 {
            return url
        }
        if let url = images?.fixedWidth?.gifUrl, url.count > 0 {
            return url
        }
        return images?.original?.gifUrl ?? ""
    }
    
    var size: CGSize {
        if let height = images?.fixedHeightSmall?.height, let width = images?.fixedHeightSmall?.width, height > 0, width > 0 {
            return CGSize(width: width, height: height)
        }
        if let height = images?.fixedWidthSmall?.height, let width = images?.fixedWidthSmall?.width, height > 0, width > 0 {
            return CGSize(width: width, height: height)
        }
        if let height = images?.fixedHeight?.height, let width = images?.fixedHeight?.width, height > 0, width > 0 {
            return CGSize(width: width, height: height)
        }
        if let height = images?.fixedWidth?.height, let width = images?.fixedWidth?.width, height > 0, width > 0 {
            return CGSize(width: width, height: height)
        }
        if let height = images?.original?.height, let width = images?.original?.width, height > 0, width > 0 {
            return CGSize(width: width, height: height)
        }
        return CGSize(width: 100, height: 100)
    }
}
