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
    
    public private(set) var gifItem: AMGiphyItem!
    
    private var previewData: Data?
    private var gifData: Data? //Video
    
    private var previewRequest: DownloadRequest?
    private var gifRequest: DownloadRequest?
    
    init(_ item: AMGiphyItem) {
        gifItem = item
    }
    
    func startLoading() {
        let isExistThumbnail = AMGiphyCacheProvider.shared.existThumbnail(gifItem.id)
        if previewRequest == nil && !isExistThumbnail {
            previewRequest = Alamofire.download(gifItem.thumbnailUrl ?? "", to: destionation(gifItem.id + "_thumbnail"))
            previewRequest?.responseData(completionHandler: {[weak self] (responce) in
                if let data = responce.value, let key = self?.gifItem.id {
                    AMGiphyCacheProvider.shared.cacheThumbnail(data, with: key)
                }
                self?.delegate?.giphyModel(self, loadedThumbnail: responce.value)
                if let destination = responce.destinationURL {
                    try? FileManager.default.removeItem(at: destination)
                }
            })
        } else if !isExistThumbnail {
            previewRequest?.resume()
        } else {
            AMGiphyCacheProvider.shared.thumbnailCache(for: gifItem.id, completion: {[weak self] (data) in
                self?.delegate?.giphyModel(self, loadedThumbnail: data)
            })
        }
        
        let isExistGif = AMGiphyCacheProvider.shared.existGif(gifItem.id)
        if gifRequest == nil && !isExistGif {
            gifRequest = Alamofire.download(gifItem.gifUrl ?? "", to: destionation(gifItem.id))
            gifRequest?.responseData(completionHandler: {[weak self] (responce) in
                if let data = responce.value, let key = self?.gifItem.id {
                    AMGiphyCacheProvider.shared.cacheGif(data, with: key, completion: { (success) in
                        if success {
                            self?.delegate?.giphyModel(self, loadedGif: AMGiphyCacheProvider.shared.gifCachePath(for: key))
                        } else {
                            self?.delegate?.giphyModel(self, loadedGif: nil)
                        }
                    })
                } else {
                    self?.delegate?.giphyModel(self, loadedGif: nil)
                }
                if let destination = responce.destinationURL {
                    try? FileManager.default.removeItem(at: destination)
                }
            })
        } else if !isExistGif {
            gifRequest?.resume()
        } else {
            self.delegate?.giphyModel(self, loadedGif: AMGiphyCacheProvider.shared.gifCachePath(for: gifItem.id))
        }
    }
    
    func stopLoading() {
        previewRequest?.suspend()
        gifRequest?.suspend()
    }
    
    private func destionation(_ name: String) -> DownloadRequest.DownloadFileDestination {
        return { _, _ in
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let documentsURL = URL(fileURLWithPath: documentsPath + "/giphy-cache", isDirectory: true)
            let fileURL = documentsURL.appendingPathComponent(name)
            _ = try? FileManager.default.createDirectory(at: documentsURL, withIntermediateDirectories: true, attributes: nil)
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
    }
}













