//
//  AMGiphyViewModel.swift
//  GiphyComponent
//
//  Created by Alexander Momotiuk on 18.01.18.
//  Copyright © 2018 Alexander Momotiuk. All rights reserved.
//

import UIKit
import AVKit
import Alamofire
import Cache

protocol AMGiphyViewModelDelegate: class {
    
    func giphyModelDidStartLoadingThumbnail(_ item: AMGiphyViewModel?)
    func giphyModelDidEndLoadingThumbnail(_ item: AMGiphyViewModel?)
    
    func giphyModel(_ item: AMGiphyViewModel?, thumbnail data: Data?)
    func giphyModel(_ item: AMGiphyViewModel?, gifAsset asset: AVAsset)
}

class AMGiphyViewModel {
    
    weak var delegate: AMGiphyViewModelDelegate?
    
    public let gifItem: AMGiphyItem
    
    private var previewRequest: DownloadRequest?
    private var gifRequest: DownloadRequest?
    
    private var gifAsset: AVAsset?
    
    init(_ item: AMGiphyItem) {
        gifItem = item
    }
    
    func prefetchData() {
        if AMGiphyCacheProvider.shared.existGif(gifItem.id) {
            createPlayer()
            return
        }
        if !AMGiphyCacheProvider.shared.existThumbnail(gifItem.id) {
            fetchThumbnail()
        }
    }
    
    func cancelPrefecth() {
        previewRequest?.suspend()
    }
    
    func fetchData() {
        if let asset = gifAsset {
            self.delegate?.giphyModel(self, gifAsset: asset)
            return
        }
        if AMGiphyCacheProvider.shared.existGif(gifItem.id) {
            createPlayer()
            return
        }
        if AMGiphyCacheProvider.shared.existThumbnail(gifItem.id) {
            AMGiphyCacheProvider.shared.thumbnailCache(for: gifItem.id, completion: {[weak self] (data) in
                self?.delegate?.giphyModel(self, thumbnail: data)
            })
            fetchGifData()
            return
        }
        fetchThumbnail({[weak self] in
            self?.fetchGifData()
        })
        
    }
    
    func stopFetching() {
        previewRequest?.suspend()
        gifRequest?.suspend()
    }
    
    //MARK: - Private Methods
    private func createPlayer() {
        guard let gifPath = AMGiphyCacheProvider.shared.gifCachePath(for: gifItem.id) else {
            return
        }
        let gifUrl = URL(fileURLWithPath: gifPath)
        gifAsset = AVAsset(url: gifUrl)
        delegate?.giphyModel(self, gifAsset: gifAsset!)
    }
    
    private func fetchThumbnail(_ completion: (()->Void)? = nil) {
        delegate?.giphyModelDidStartLoadingThumbnail(self)
        previewRequest = Alamofire.download(gifItem.thumbnailUrl ?? "", to: destionation(gifItem.id + "_thumbnail"))
        previewRequest?.responseData(completionHandler: {[weak self] (responce) in
            if let data = responce.value, let key = self?.gifItem.id {
                AMGiphyCacheProvider.shared.cacheThumbnail(data, with: key)
            }
            
            self?.delegate?.giphyModelDidEndLoadingThumbnail(self)
            
            self?.delegate?.giphyModel(self, thumbnail: responce.value)
            self?.removeTemporaryCache(responce.destinationURL)
            
            if let callback = completion {
                callback()
            }
        })
    }
    
    private func fetchGifData() {
        gifRequest = Alamofire.download(gifItem.gifUrl ?? "", to: destionation(gifItem.id))
        gifRequest?.responseData(completionHandler: {[weak self] (responce) in
            if let data = responce.value, let key = self?.gifItem.id {
                AMGiphyCacheProvider.shared.cacheGif(data, with: key, completion: { (success) in
                    if success {
                        self?.createPlayer()
                    }
                })
            }
            self?.removeTemporaryCache(responce.destinationURL)
        })
    }
    
    private func removeTemporaryCache(_ url: URL?) {
        guard let temporaryURL = url else {
            return
        }
        try? FileManager.default.removeItem(at: temporaryURL)
    }
    
    private func destionation(_ name: String) -> DownloadRequest.DownloadFileDestination {
        return { _, _ in
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let documentsURL = URL(fileURLWithPath: documentsPath + "/giphy-temporary-cache", isDirectory: true)
            let fileURL = documentsURL.appendingPathComponent(name)
            _ = try? FileManager.default.createDirectory(at: documentsURL, withIntermediateDirectories: true, attributes: nil)
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
    }
}
