//
//  AMGifWrapper.swift
//  AMGiphyPicker
//
//  Created by Alexander Momotiuk on 11.01.18.
//  Copyright © 2018 Alexander Momotiuk. All rights reserved.
//

import UIKit

protocol AMGifWrapper {
    
    var key: String { get }
    var thumbnailUrl: String { get }
    var gifUrl: String { get }
    var size: CGSize { get }
}


