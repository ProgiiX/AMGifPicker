//
//  AMGiphyPickerSettings.swift
//  AMGiphyPicker
//
//  Created by Alexander Momotiuk on 1/23/18.
//  Copyright © 2018 Alexander Momotiuk. All rights reserved.
//

import Foundation

enum AMGiphyPickerScrollDirection {
    case horizontal
}

struct AMGiphyPickerConfiguration {
    
    static var defaultConfiguration: AMGiphyPickerConfiguration {
        return AMGiphyPickerConfiguration()
    }
    
    public private(set) var numberRows: Int 
    public private(set) var scrollDirection: AMGiphyPickerScrollDirection
    
    // Maximum gifs for one search string
    public private(set) var maxLoadCount: Int
    
    init(rows: Int = 2, direction: AMGiphyPickerScrollDirection = .horizontal, maxCount: Int = 200) {
        numberRows = rows
        scrollDirection = direction
        maxLoadCount = maxCount
    }
}
