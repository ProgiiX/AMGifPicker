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
    
    private static var _shared: AMGiphyDataProvider?
    
    @objc static var shared: AMGiphyDataProvider {
        if _shared == nil {
            _shared = AMGiphyDataProvider()
        }
        return _shared!
    }
    
    let client: GPHClient!
    
    private var sharedTrending: [AMGiphyItem] = []
    
    private override init() {
        let cache = AMGiphyCacheProvider()
        client = GPHClient(apiKey: "64RLJtsFr7zEXrFbzsAetbduFJU3qpF6")
    }
    
    func getGiphy(_ search: String? = nil, completion: @escaping (_ data: [AMGiphyItem]) -> Void) {
        if let searchString = search {
            client.search(searchString, completionHandler: { (responce, error) in
                completion(AMGiphyDataProvider.convertToItem(responce?.data ?? []))
            })
        } else {
            client.trending { (responce, error) in
                completion(AMGiphyDataProvider.convertToItem(responce?.data ?? []))
            }
        }
    }
    
    private static func convertToItem(_ giphy: [GPHMedia]) -> [AMGiphyItem] {
        let result = giphy.map { (giphy) -> AMGiphyItem in
            let width = giphy.images?.fixedHeightSmallStill?.width ?? 100
            let height = giphy.images?.fixedHeight?.height ?? 100
            let size = CGSize(width: width, height: height)
            return AMGiphyItem(giphy.id, thumbnail: giphy.images?.fixedHeightSmallStill?.gifUrl, gif: giphy.images?.fixedHeightSmall?.mp4Url, size: size)
        }
        return result
    }
}
