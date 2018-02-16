//
//  ViewController.swift
//  GiphyComponent
//
//  Created by Alexander Momotiuk on 09.01.18.
//  Copyright © 2018 Alexander Momotiuk. All rights reserved.
//

import UIKit
import FLAnimatedImage

class ViewController: UIViewController, AMGifPickerDelegate, AMGifViewModelDelegate {
    
    func gifPicker(_ picker: AMGifPicker, didSelected gif: AMGif) {
        let newGif = gif.translate(preferred: .low)
        
        gifModel = AMGifViewModel.init(newGif)
        gifModel?.delegate = self
        gifModel?.fetchData()
        
        heightConstr.constant = newGif.size.height
        widthConstr.constant = newGif.size.width
    }
    
    var gifView: AMGifPicker!
    
    var imageView = FLAnimatedImageView()
    var gifModel: AMGifViewModel?
    var heightConstr: NSLayoutConstraint!
    var widthConstr: NSLayoutConstraint!
    
    @IBOutlet weak var searchField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let configuration = AMGifPickerConfiguration(apiKey: "64RLJtsFr7zEXrFbzsAetbduFJU3qpF6", direction: .horizontal)
        gifView = AMGifPicker(configuration: configuration)
        view.addSubview(gifView)
        gifView.translatesAutoresizingMaskIntoConstraints = false
        
        gifView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        gifView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        gifView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        gifView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        gifView.delegate = self
        
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.leftAnchor.constraint(greaterThanOrEqualTo: view.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(lessThanOrEqualTo: view.rightAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        heightConstr = imageView.heightAnchor.constraint(equalToConstant: 200)
        widthConstr = imageView.widthAnchor.constraint(equalToConstant: 200)
        heightConstr.isActive = true
        widthConstr.isActive = true
    }
    
    @IBAction func click(_ sender: Any) {
        searchField.resignFirstResponder()
        gifView.search(searchField.text)
    }
    
    func giphyModelDidBeginLoadingThumbnail(_ item: AMGifViewModel?) {}
    func giphyModelDidEndLoadingThumbnail(_ item: AMGifViewModel?) {}
    func giphyModelDidBeginLoadingGif(_ item: AMGifViewModel?) {}
    
    func giphyModel(_ item: AMGifViewModel?, thumbnail data: Data?) {
        imageView.animatedImage = FLAnimatedImage(animatedGIFData: data)
    }
    
    func giphyModel(_ item: AMGifViewModel?, gifData data: Data?) {
        imageView.animatedImage = FLAnimatedImage(animatedGIFData: data)
    }
    
    func giphyModel(_ item: AMGifViewModel?, gifProgress progress: CGFloat) {}
    
}

