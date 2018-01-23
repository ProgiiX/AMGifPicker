//
//  AMGiphyCacheProvider.swift
//  GiphyComponent
//
//  Created by Alexander Momotiuk on 15.01.18.
//  Copyright © 2018 Alexander Momotiuk. All rights reserved.
//

import Foundation
import Cache

fileprivate let megabyte: UInt = 1024 * 1024
fileprivate let hour: TimeInterval = 60 * 60

enum AMGiphyCacheType {
    case trending
    case search
}

class AMGiphyCacheProvider {
    
    static let shared = AMGiphyCacheProvider()
    
    private var thumbnailsStorage: Storage!
    private var gifsStorage: Storage!
    
    private init() {
        let mainDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let cacheDirectory = URL(string: mainDirectoryUrl.absoluteString + "/giphy-cache")!
        
        initStorage(cacheDirectory)
    }
    
    private func initStorage(_ url: URL) {
        let thumbnailsMemoryConfig = DiskConfig(name: "thumbnails", expiry: .seconds(hour), maxSize: megabyte * 10, directory: url, protectionType: nil)
        let gifsMemoryConfig = DiskConfig(name: "gifs", expiry: .seconds(hour), maxSize: megabyte * 50, directory: url, protectionType: nil)
        
        thumbnailsStorage = try! Storage(diskConfig: thumbnailsMemoryConfig)
        gifsStorage = try! Storage(diskConfig: gifsMemoryConfig)
    }
    
    func cacheThumbnail(_ data: Data, with key: String) {
        thumbnailsStorage.async.setObject(data, forKey: key + "_thumbnail") { (result) in }
    }
    
    func cacheGif(_ data: Data, with key: String, completion: @escaping (Bool) -> Void) {
        gifsStorage.async.setObject(data, forKey: key) { (result) in
            switch result {
            case .value(_):
                completion(true)
            case .error(_):
                completion(false)
            }
        }
    }
    
    func thumbnailCache(for key: String, completion: @escaping (Data?) -> Void) {
        thumbnailsStorage.async.object(ofType: Data.self, forKey: key + "_thumbnail") { (result) in
            switch result {
            case .value(let data):
                completion(data)
            case .error(_):
                completion(nil)
            }
        }
    }
    
    func gifCache(for key: String, completion: @escaping (Data?) -> Void) {
        gifsStorage.async.object(ofType: Data.self, forKey: key) { (result) in
            switch result {
            case .value(let data):
                completion(data)
            case .error(_):
                completion(nil)
            }
        }
    }
    
    func thumbnailCachePath(for key: String) -> String? {
        return thumbnailsStorage.makeFilePath(key + "_thumbnail")
    }
    
    func gifCachePath(for key: String) -> String? {
        return gifsStorage.makeFilePath(key)
    }
    
    func existThumbnail(_ key: String) -> Bool {
        do {
            return try thumbnailsStorage.existsObject(ofType: Data.self, forKey: key + "_thumbnail")
        } catch {
            return false
        }
    }
    
    func existGif(_ key: String) -> Bool {
        do {
            return try gifsStorage.existsObject(ofType: Data.self, forKey: key)
        } catch {
            return false
        }
    }
}










