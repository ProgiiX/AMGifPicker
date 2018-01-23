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

struct AMGiphyPickerSettings {
    
    static var defaultSettings: AMGiphyPickerSettings {
        return AMGiphyPickerSettings()
    }
    
    public private(set) var numberRows: Int = 2
    public private(set) var scrollDirection: AMGiphyPickerScrollDirection = .horizontal
    
    // Maximum gifs for one search string
    public private(set) var maxLoadCount: Int = 200
    
    init(rows: Int = 2, direction: AMGiphyPickerScrollDirection = .horizontal, maxCount: Int = 200) {
        numberRows = rows
        scrollDirection = direction
        maxLoadCount = maxCount
    }
}
