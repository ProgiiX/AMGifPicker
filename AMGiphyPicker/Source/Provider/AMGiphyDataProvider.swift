//
//  AMGiphyDataProvider.swift
//  Cadence
//
//  Created by Alexander Momotiuk on 09.01.18.
//  Copyright © 2018 Cadence. All rights reserved.
//

import Foundation
import GiphyCoreSDK

fileprivate struct Configuration {
    static let limit = 40
}

class AMGiphyDataProvider {
    
    private var configuration: AMGiphyPickerConfiguration
    private let client: GPHClient
    
    private var trendingGifs: Set<AMGiphyItem> = []
    private var searchGifs: Set<AMGiphyItem> = []
    
    private var searchString: String? = nil
    
    init(_ configuration: AMGiphyPickerConfiguration) {
        self.configuration = configuration
        self.client = GPHClient(apiKey: "64RLJtsFr7zEXrFbzsAetbduFJU3qpF6")
    }
    
    func loadGiphy(_ search: String? = nil, offset: Int = 0, completion: @escaping (_ data: [AMGiphyItem]) -> Void) {
        // Loaded Max Gifs Count
        
        //FIX ME
        if offset >= configuration.maxLoadCount
            || (search == nil && trendingGifs.count >= configuration.maxLoadCount)
            || (search != nil && searchGifs.count >= configuration.maxLoadCount) {
            completion([])
            return
        }
        
        // Search
        if let search = search {
            getSearchGifs(search, offset: offset, completion: {[weak self] (items) in
                guard let strongSelf = self else { return }
                strongSelf.searchGifs = strongSelf.searchGifs.union(items)
                completion(items)
            })
        } else {
            // Trending
            // Clear Search Cache
            searchString = nil
            searchGifs.removeAll()
            AMGiphyCacheProvider.shared.cleanCache()
            
            getTrendingGifs(offset: offset, completion: {[weak self] (items) in
                guard let strongSelf = self else { return }
                strongSelf.trendingGifs = strongSelf.trendingGifs.union(items)
                completion(items)
            })
        }
    }
    
    private func getSearchGifs(_ search: String, offset: Int, completion: @escaping (_ data: [AMGiphyItem]) -> Void) {
        client.search(search, offset: offset, limit: Configuration.limit, completionHandler: { (responce, error) in
            guard let responceItems = responce?.data else {
                return
            }
            let gifs: [AMGiphyItem] = responceItems.map { return AMGiphyItem($0) }
            completion(gifs)
        })
    }
    
    private func getTrendingGifs(offset: Int, completion: @escaping (_ data: [AMGiphyItem]) -> Void) {
        client.trending(offset: offset, limit: Configuration.limit) { (responce, error) in
            guard let responceItems = responce?.data else {
                return
            }
            let gifs: [AMGiphyItem] = responceItems.map { return AMGiphyItem($0) }
            completion(gifs)
        }
    }

}
