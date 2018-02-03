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
    

    var gifView: AMGifPicker!
    
    @IBOutlet weak var searchField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let configuration = AMGifPickerConfiguration(apiKey: "64RLJtsFr7zEXrFbzsAetbduFJU3qpF6", direction: .vertical)
        gifView = AMGifPicker(configuration: configuration)
        view.addSubview(gifView)
        gifView.translatesAutoresizingMaskIntoConstraints = false
        
        gifView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        gifView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        gifView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        gifView.heightAnchor.constraint(equalToConstant: 600).isActive = true
        
        gifView.delegate = self
    }
    
    @IBAction func click(_ sender: Any) {
        searchField.resignFirstResponder()
        gifView.search(searchField.text)
    }
    
}

