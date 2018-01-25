//
//  AMGiphyViewModel.swift
//  GiphyComponent
//
//  Created by Alexander Momotiuk on 18.01.18.
//  Copyright © 2018 Alexander Momotiuk. All rights reserved.
//

import UIKit
import Alamofire
import Cache

protocol AMGiphyViewModelDelegate: class {
    
    func giphyModelDidBeginLoadingThumbnail(_ item: AMGiphyViewModel?)
    func giphyModelDidEndLoadingThumbnail(_ item: AMGiphyViewModel?)
    
    func giphyModelDidBeginLoadingGif(_ item: AMGiphyViewModel?)
    
    func giphyModel(_ item: AMGiphyViewModel?, thumbnail data: Data?)
    func giphyModel(_ item: AMGiphyViewModel?, gifData data: Data?)
    
    func giphyModel(_ item: AMGiphyViewModel?, gifProgress progress: CGFloat)
}

class AMGiphyViewModel {
    
    weak var delegate: AMGiphyViewModelDelegate?
    
    public let gifItem: AMGiphyItem
    
    private var previewRequest: DownloadRequest?
    private var gifRequest: DownloadRequest?
    
    init(_ item: AMGiphyItem) {
        gifItem = item
    }
    
    func prefetchData() {
        if AMGiphyCacheProvider.shared.existGif(gifItem.id) {
            self.delegate?.giphyModel(self, gifData: AMGiphyCacheProvider.shared.gifCache(for: gifItem.id))
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
        if AMGiphyCacheProvider.shared.existGif(gifItem.id) {
            self.delegate?.giphyModel(self, gifData: AMGiphyCacheProvider.shared.gifCache(for: gifItem.id))
            return
        }
        if AMGiphyCacheProvider.shared.existThumbnail(gifItem.id) {
            self.delegate?.giphyModel(self, thumbnail: AMGiphyCacheProvider.shared.thumbnailCache(for: gifItem.id))
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
    private func fetchThumbnail(_ completion: (()->Void)? = nil) {
        delegate?.giphyModelDidBeginLoadingThumbnail(self)
        
        if previewRequest != nil, let suspend = previewRequest?.delegate.queue.isSuspended, suspend {
            self.previewRequest?.resume()
        } else {
            self.previewRequest = Alamofire.download(self.gifItem.thumbnailUrl ?? "", to: self.destionation(self.gifItem.id + "_thumbnail"))
            self.previewRequest?.responseData(completionHandler: {[weak self] (responce) in
                if responce.error != nil {
                    self?.previewRequest = nil
                    return
                }
                
                if let data = responce.value, let key = self?.gifItem.id {
                    AMGiphyCacheProvider.shared.cacheThumbnail(data, with: key)
                }
                
                self?.delegate?.giphyModelDidEndLoadingThumbnail(self)
                
                self?.delegate?.giphyModel(self, thumbnail: responce.value)
                self?.removeTemporaryCache(responce.destinationURL)
                self?.previewRequest = nil
                
                if let callback = completion {
                    callback()
                }
            })
        }
    }
    
    private func fetchGifData() {
        self.delegate?.giphyModelDidBeginLoadingGif(self)
        
        if gifRequest != nil, let suspend = gifRequest?.delegate.queue.isSuspended, suspend {
            self.gifRequest?.resume()
        } else {
            self.gifRequest = Alamofire.download(self.gifItem.gifUrl ?? "", to: self.destionation(self.gifItem.id))
            self.gifRequest?.responseData(completionHandler: {[weak self] (responce) in
                if responce.error != nil {
                    self?.gifRequest = nil
                    return
                }
                if let data = responce.value, let key = self?.gifItem.id {
                    AMGiphyCacheProvider.shared.cacheGif(data, with: key, completion: { (success) in
                        if success {
                            self?.delegate?.giphyModel(self, gifData: data)
                        }
                    })
                }
                self?.removeTemporaryCache(responce.destinationURL)
                self?.gifRequest = nil
            })
            self.gifRequest?.downloadProgress(queue: DispatchQueue.main, closure: {[weak self] (progress) in
                self?.delegate?.giphyModel(self, gifProgress: CGFloat(progress.fractionCompleted))
            })
        }
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
