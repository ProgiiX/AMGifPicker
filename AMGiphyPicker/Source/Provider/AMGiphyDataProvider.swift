//
//  AMGiphyDataProvider.swift
//  Cadence
//
//  Created by Alexander Momotiuk on 09.01.18.
//  Copyright © 2018 Cadence. All rights reserved.
//

import Foundation
import GiphyCoreSDK

class AMGiphyDataProvider: NSObject {
    
    private struct Constants {
        static let limit = 20
        static let maxLoadCount = 100
    }
    
    private static var _shared: AMGiphyDataProvider?
    
    @objc static var shared: AMGiphyDataProvider {
        if _shared == nil {
            _shared = AMGiphyDataProvider()
        }
        return _shared!
    }
    
    let client: GPHClient!
    
    private var trendingGifs: Set<AMGiphyItem> = []
    private var searchGifs: Set<AMGiphyItem> = []
    
    private var searchString: String? = nil
    
    private override init() {
        client = GPHClient(apiKey: "64RLJtsFr7zEXrFbzsAetbduFJU3qpF6")
    }
    
    func loadGiphy(_ search: String? = nil, offset: Int = 0, completion: @escaping (_ data: [AMGiphyItem]) -> Void) {
        // Loaded Max Gifs Count
        if offset >= Constants.maxLoadCount
            || (search == nil && trendingGifs.count >= Constants.maxLoadCount)
            || (search != nil && searchGifs.count >= Constants.maxLoadCount) {
            completion([])
            return
        }
        
        // Search
        if let _ = search {
            
        } else {
            // Trending
            // Clear Search Cache
            searchString = nil
            searchGifs.removeAll()
            
            
        }
    }
    
    private func getSearchGifs(_ search: String, offset: Int, completion: @escaping (_ data: [AMGiphyItem]) -> Void) {
        client.search(search, offset: offset, limit: Constants.limit, completionHandler: { (responce, error) in
            completion(AMGiphyDataProvider.convertToItem(responce?.data ?? []))
        })
    }
    
    private func getTrendingGifs(offset: Int, completion: @escaping (_ data: [AMGiphyItem]) -> Void) {
        client.trending(offset: offset, limit: Constants.limit) { (responce, error) in
            completion(AMGiphyDataProvider.convertToItem(responce?.data ?? []))
        }
    }
    
    private static func convertToItem(_ giphy: [GPHMedia]) -> [AMGiphyItem] {
        let result = giphy.map { (giphy) -> AMGiphyItem in
            let width = giphy.images?.fixedHeightSmall?.width ?? 100
            let height = giphy.images?.fixedHeightSmall?.height ?? 100
            let size = CGSize(width: width, height: height)
            return AMGiphyItem(giphy.id, thumbnail: giphy.images?.fixedHeightSmallStill?.gifUrl, gif: giphy.images?.fixedHeightSmall?.mp4Url, size: size)
        }
        return result
    }
}
