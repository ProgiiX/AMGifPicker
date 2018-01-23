//
//  AMGiphyCell.swift
//  GiphyComponent
//
//  Created by Alexander Momotiuk on 09.01.18.
//  Copyright © 2018 Alexander Momotiuk. All rights reserved.
//

import UIKit
import GiphyCoreSDK
import FLAnimatedImage
import AVKit

class AMGiphyCell: UICollectionViewCell {
    
    private var model: AMGiphyViewModel!
    let imageView = UIImageView()
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    var player: AVPlayer?
    let playerLayer = AVPlayerLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        setupLayout()
    }
    
    private func setupLayout() {
        contentView.layer.addSublayer(playerLayer)
        playerLayer.backgroundColor = UIColor.clear.cgColor
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        contentView.addSubview(indicator)
        indicator.isHidden = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        indicator.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        indicator.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        indicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    func setupWith(_ media: AMGiphyViewModel) {
        model = media
        model.delegate = self
        model.fetchData()
        startIndicator()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    @objc private func videoLoop() {
        player?.pause()
        player?.currentItem?.seek(to: kCMTimeZero, completionHandler: nil)
        player?.play()
    }
 
    //MARK: - Loading Indicator
    private func startIndicator() {
        DispatchQueue.main.async {
            self.indicator.startAnimating()
            self.indicator.isHidden = false
        }
    }
    
    private func stopIndicator() {
        DispatchQueue.main.async {
            self.indicator.isHidden = true
            self.indicator.stopAnimating()
        }
    }
     
    override func prepareForReuse() {
        super.prepareForReuse()
        model.delegate = nil
        model.stopFetching()
        model = nil
        
        imageView.image = nil
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        player = nil
        playerLayer.player = nil
        playerLayer.opacity = 0.0
    }
}

extension AMGiphyCell: AMGiphyViewModelDelegate {
    
    func giphyModel(_ item: AMGiphyViewModel?, loadedGif path: String?) {
        if let path = path {
            DispatchQueue.main.async {
                self.stopIndicator()
                let url = URL(fileURLWithPath: path)
                self.player = AVPlayer(url: url)
                self.playerLayer.player = self.player
                
                self.player?.play()
                NotificationCenter.default.addObserver(self, selector: #selector(self.videoLoop), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)
                
                self.imageView.isHidden = true
                self.imageView.image = nil
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.playerLayer.opacity = 1.0
                })
            }
        }
    }
    
    func giphyModel(_ item: AMGiphyViewModel?, loadedThumbnail data: Data?) {
        DispatchQueue.main.async {
            self.stopIndicator()
            if let imageData = data {
                UIView.transition(with: self.imageView,
                                  duration: 0.2,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                    self.imageView.image = UIImage(data: imageData)
                                  },
                                  completion: nil)
            }
        }
    }
}














