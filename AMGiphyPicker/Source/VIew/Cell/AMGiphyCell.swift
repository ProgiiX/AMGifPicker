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
        playerLayer.backgroundColor = UIColor.clear.cgColor
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        contentView.layer.addSublayer(playerLayer)
        
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
        if !self.indicator.isAnimating {
            DispatchQueue.main.async {
                self.indicator.startAnimating()
                self.indicator.isHidden = false
            }
            
        }
    }
    
    private func stopIndicator() {
        if self.indicator.isAnimating {
            DispatchQueue.main.async {
                self.indicator.isHidden = true
                self.indicator.stopAnimating()
            }
        }
    }
     
    override func prepareForReuse() {
        stopIndicator()
        
        model.delegate = nil
        model.stopFetching()
        model = nil
        
        imageView.image = nil
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerLayer.player?.currentItem)
        playerLayer.player = nil
        
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    @objc private func videoLoop() {
        playerLayer.player?.pause()
        playerLayer.player?.currentItem?.seek(to: kCMTimeZero, completionHandler: nil)
        playerLayer.player?.play()
    }
    
}

extension AMGiphyCell: AMGiphyViewModelDelegate {
    
    func giphyModelDidStartLoadingThumbnail(_ item: AMGiphyViewModel?) {
        startIndicator()
    }
    
    func giphyModelDidEndLoadingThumbnail(_ item: AMGiphyViewModel?) {
        stopIndicator()
    }
    
    func giphyModel(_ item: AMGiphyViewModel?, thumbnail data: Data?) {
        DispatchQueue.main.async {
            if let imageData = data {
                UIView.transition(with: self.imageView,
                                  duration: 0.15,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                    self.imageView.image = UIImage(data: imageData)
                },
                                  completion: nil)
            }
        }
    }
    
    func giphyModel(_ item: AMGiphyViewModel?, gifAsset asset: AVAsset) {
        DispatchQueue.main.async {
            let playerItem = AVPlayerItem(asset: asset)
            let player = AVPlayer(playerItem: playerItem)
            self.playerLayer.player = player
            player.play()
            
            self.imageView.isHidden = true
            self.imageView.image = nil
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.videoLoop), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerLayer.player!.currentItem)
        }
    }
}














