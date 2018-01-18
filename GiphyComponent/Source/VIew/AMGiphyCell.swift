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
import Alamofire
import AVKit

class AMGiphyCell: UICollectionViewCell , AVAssetResourceLoaderDelegate{
    
    private var data: AMGiphyItem!
    let imageView = FLAnimatedImageView()
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var thumbRequest: DownloadRequest?
    var gifRequest: DownloadRequest?
    
    var videoPlayer: AVPlayer!
    var videoLayer: AVPlayerLayer = AVPlayerLayer()
    
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
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true

        addSubview(indicator)
        indicator.isHidden = true
        indicator.translatesAutoresizingMaskIntoConstraints = false

        indicator.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        indicator.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        indicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoLayer.frame = bounds
    }
    
    func setupWith(_ media: AMGiphyItem) {
        data = media
        guard let url = URL(string: media.gifUrl ?? "") else {
            return
        }
        
        let asset = AVURLAsset(url: url)
        asset.resourceLoader.setDelegate(self, queue: DispatchQueue.global())
        let item = AVPlayerItem(asset: asset)
        videoLayer.player = videoPlayer
        videoLayer.frame = bounds
       // layer.addSublayer(videoLayer)
        //videoPlayer!.play()

        //NotificationCenter.default.addObserver(self, selector: #selector(videoLoop), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: videoPlayer!.currentItem)
        
        thumbRequest = Alamofire.download(media.thumbnailUrl ?? "", to: destionation("\(media.id).png"))
        thumbRequest?.responseData(completionHandler: {[weak self] (responce) in
            if responce.request?.url?.absoluteString == self?.data.thumbnailUrl, let gifData = responce.result.value {
                DispatchQueue.main.async {
                    UIView.transition(with: self!.imageView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        self?.imageView.animatedImage = FLAnimatedImage(animatedGIFData: gifData)
                    }, completion: nil)
                }
            }
        })
        
//        gifRequest = Alamofire.download(path, to: destionation("\(media.id).gif"))
//        gifRequest?.responseData {[weak self] (responce) in
//            self?.stopIndicator()
//            if responce.request?.url?.absoluteString == self?.data.gifUrl, let gifData = responce.result.value {
//                self?.thumbRequest?.cancel()
//                DispatchQueue.main.async {
//                    self?.imageView.animatedImage = FLAnimatedImage(animatedGIFData: gifData)
//                    self?.layoutIfNeeded()
//                }
//            }
//        }
    }
    
    @objc private func videoLoop() {
        self.videoPlayer?.pause()
        self.videoPlayer?.currentItem?.seek(to: kCMTimeZero, completionHandler: nil)
        self.videoPlayer?.play()
    }
    
    func destionation(_ name: String) -> DownloadRequest.DownloadFileDestination {
        return { _, _ in
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let documentsURL = URL(fileURLWithPath: documentsPath + "giphy-cache", isDirectory: true)
            let fileURL = documentsURL.appendingPathComponent(name)
            _ = try? FileManager.default.createDirectory(at: documentsURL, withIntermediateDirectories: true, attributes: nil)
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
    }
    
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
        stopIndicator()
        data = nil
        thumbRequest?.cancel()
        gifRequest?.cancel()
        imageView.animatedImage = nil
    }
    
}
