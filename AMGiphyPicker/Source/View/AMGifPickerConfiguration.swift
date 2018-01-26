//
//  AMGiphyPickerSettings.swift
//  AMGiphyPicker
//
//  Created by Alexander Momotiuk on 1/23/18.
//  Copyright © 2018 Alexander Momotiuk. All rights reserved.
//

import Foundation

enum AMGifPickerScrollDirection {
    case horizontal
}

struct AMGifPickerConfiguration {
    
    public let apiKey: String
    public let numberRows: Int
    public let scrollDirection: AMGifPickerScrollDirection
    
    // Maximum gifs for one search string
    public let maxLoadCount: Int
    
    init(apiKey key: String, rows: Int = 2, direction: AMGifPickerScrollDirection = .horizontal, maxCount: Int = 200) {
        apiKey = key
        numberRows = rows
        scrollDirection = direction
        maxLoadCount = maxCount
    }
}
