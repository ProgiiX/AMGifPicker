//
//  ViewController.swift
//  GiphyComponent
//
//  Created by Alexander Momotiuk on 09.01.18.
//  Copyright © 2018 Alexander Momotiuk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var gifView: AMGifPicker!
    
    @IBOutlet weak var progress: AMGifProgress!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        
        
    }

    
    @IBAction func click(_ sender: Any) {
        progress.updateIndicator(with: 90, isAnimated: true)
        
    }
    
}

