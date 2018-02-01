//
//  AMGifViewModel.swift
//  GiphyComponent
//
//  Created by Alexander Momotiuk on 18.01.18.
//  Copyright © 2018 Alexander Momotiuk. All rights reserved.
//

import UIKit
import Alamofire
import Cache

protocol AMGifViewModelDelegate: class {
    
    func giphyModelDidBeginLoadingThumbnail(_ item: AMGifViewModel?)
    func giphyModelDidEndLoadingThumbnail(_ item: AMGifViewModel?)
    
    func giphyModelDidBeginLoadingGif(_ item: AMGifViewModel?)
    
    func giphyModel(_ item: AMGifViewModel?, thumbnail data: Data?)
    func giphyModel(_ item: AMGifViewModel?, gifData data: Data?)
    
    func giphyModel(_ item: AMGifViewModel?, gifProgress progress: CGFloat)
}

class AMGifViewModel {
    
    weak var delegate: AMGifViewModelDelegate?
    
    let gifItem: AMGif
    
    fileprivate var previewRequest: DownloadRequest?
    fileprivate var gifRequest: DownloadRequest?
    
    init(_ item: AMGif) {
        gifItem = item
    }
    
    //MARK: - Fetch Data
    func fetchData() {
        if AMGifCacheManager.shared.existGif(gifItem.id) {
            self.delegate?.giphyModel(self, gifData: AMGifCacheManager.shared.gifCache(for: gifItem.id))
            return
        }
        if AMGifCacheManager.shared.existThumbnail(gifItem.id) {
            self.delegate?.giphyModel(self, thumbnail: AMGifCacheManager.shared.thumbnailCache(for: gifItem.id))
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
    
    //MARK: - Pre-fetching methods
    func prefetchData() {
        if AMGifCacheManager.shared.existGif(gifItem.id) {
            self.delegate?.giphyModel(self, gifData: AMGifCacheManager.shared.gifCache(for: gifItem.id))
            return
        }
        if !AMGifCacheManager.shared.existThumbnail(gifItem.id) {
            fetchThumbnail()
        }
    }
    
    func cancelPrefecth() {
        previewRequest?.suspend()
    }
    
    //MARK: - Cancel
    func cancelFetching() {
        previewRequest?.cancel()
        gifRequest?.cancel()
    }
    
    //MARK: - Private Methods
    private func fetchThumbnail(_ completion: (()->Void)? = nil) {
        delegate?.giphyModelDidBeginLoadingThumbnail(self)
        
        if previewRequest != nil, let suspend = previewRequest?.delegate.queue.isSuspended, suspend, previewRequest?.delegate == nil {
            self.previewRequest?.resume()
        } else {
            self.previewRequest = Alamofire.download(self.gifItem.thumbnailUrl ?? "", to: self.destionation(self.gifItem.id + "_thumbnail"))
            self.previewRequest?.responseData(completionHandler: {[weak self] (responce) in
                if responce.error != nil {
                    self?.previewRequest = nil
                    return
                }
                
                if let data = responce.value, let key = self?.gifItem.id {
                    AMGifCacheManager.shared.cacheThumbnail(data, with: key)
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
        
        if gifRequest != nil, let suspend = gifRequest?.delegate.queue.isSuspended, suspend, gifRequest?.delegate == nil {
            self.gifRequest?.resume()
        } else {
            self.gifRequest = Alamofire.download(self.gifItem.gifUrl ?? "", to: self.destionation(self.gifItem.id))
            self.gifRequest?.responseData(completionHandler: {[weak self] (responce) in
                if responce.error != nil {
                    self?.gifRequest = nil
                    return
                }
                if let data = responce.value, let key = self?.gifItem.id {
                    AMGifCacheManager.shared.cacheGif(data, with: key, completion: { (success) in
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

extension AMGifViewModel: Hashable {
    
    static func ==(lhs: AMGifViewModel, rhs: AMGifViewModel) -> Bool {
        return lhs.gifItem.id == rhs.gifItem.id
    }
    
    var hashValue: Int {
        return gifItem.hashValue
    }
}
