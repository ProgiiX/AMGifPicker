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
    
    func giphyModel(_ item: AMGiphyViewModel?, loadedThumbnail data: Data?)
    func giphyModel(_ item: AMGiphyViewModel?, loadedGif path: String?)
}

class AMGiphyViewModel {
    
    weak var delegate: AMGiphyViewModelDelegate?
    
    public let gifItem: AMGiphyItem
    
    private var previewData: Data?
    private var gifData: Data? //Video
    
    private var previewRequest: DownloadRequest?
    private var gifRequest: DownloadRequest?
    
    init(_ item: AMGiphyItem) {
        gifItem = item
    }
    
    func prefetchData() {
        if !AMGiphyCacheProvider.shared.existThumbnail(gifItem.id) {
            fetchThumbnail()
        }
    }
    
    func cancelPrefecth() {
        previewRequest?.suspend()
    }
    
    func fetchData() {
        if AMGiphyCacheProvider.shared.existGif(gifItem.id) {
            self.delegate?.giphyModel(self, loadedGif: AMGiphyCacheProvider.shared.gifCachePath(for: gifItem.id))
        } else if AMGiphyCacheProvider.shared.existThumbnail(gifItem.id) {
            AMGiphyCacheProvider.shared.thumbnailCache(for: gifItem.id, completion: {[weak self] (data) in
                self?.delegate?.giphyModel(self, loadedThumbnail: data)
            })
            fetchGifData()
        } else {
            fetchThumbnail({[weak self] in
                self?.fetchGifData()
           })
        }
    }
    
    func stopFetching() {
        previewRequest?.suspend()
        gifRequest?.suspend()
    }
    
    
    //MARK: - Private Methods
    private func fetchThumbnail(_ completion: (()->Void)? = nil) {
        previewRequest = Alamofire.download(gifItem.thumbnailUrl ?? "", to: destionation(gifItem.id + "_thumbnail"))
        previewRequest?.responseData(completionHandler: {[weak self] (responce) in
            if let data = responce.value, let key = self?.gifItem.id {
                AMGiphyCacheProvider.shared.cacheThumbnail(data, with: key)
            }
            self?.delegate?.giphyModel(self, loadedThumbnail: responce.value)
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
                        self?.delegate?.giphyModel(self, loadedGif: AMGiphyCacheProvider.shared.gifCachePath(for: key))
                    }
                })
            } else {
                self?.delegate?.giphyModel(self, loadedGif: nil)
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
