//
//  ViewController.swift
//  GiphyComponent
//
//  Created by Alexander Momotiuk on 09.01.18.
//  Copyright © 2018 Alexander Momotiuk. All rights reserved.
//

import UIKit

class ViewController: UIViewController, AMGifPickerDelegate {
    func gifPicker(_ picker: AMGifPicker, didSelected gif: AMGif) {
        print(gif.id)
    }
    

    @IBOutlet weak var gifView: AMGifPicker!
    
    @IBOutlet weak var searchField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gifView.delegate = self
    }
    
    @IBAction func click(_ sender: Any) {
        searchField.resignFirstResponder()
        gifView.search(searchField.text)
    }
    
}

