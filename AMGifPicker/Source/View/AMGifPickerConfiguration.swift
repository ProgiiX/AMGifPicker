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
    case vertical
}

struct AMGifPickerConfiguration {
    
    let apiKey: String
    let numberRows: Int
    let scrollDirection: AMGifPickerScrollDirection
    
    // Maximum gifs for one search string
    let maxLoadCount: Int
    
    init(apiKey key: String, rows: Int = 2, direction: AMGifPickerScrollDirection = .horizontal, maxCount: Int = 200) {
        apiKey = key
        numberRows = rows
        scrollDirection = direction
        maxLoadCount = maxCount
    }
}
