//
//  AMGiphyCacheProvider.swift
//  GiphyComponent
//
//  Created by Alexander Momotiuk on 15.01.18.
//  Copyright © 2018 Alexander Momotiuk. All rights reserved.
//

import Foundation

enum AMGiphyCacheType {
    case trending
    case search
}

class AMGiphyCacheProvider {
    
    private var cacheDirectory: URL!
    private var trendingDirectory: URL!
    private var searchDirectory: URL!
    
    init() {
        let mainDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            let cacheDirectory = URL(string: mainDirectoryUrl.absoluteString + "/giphy-cache")!
            try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
            
            let trendingDirectory = URL(string: cacheDirectory.absoluteString + "/giphy-cache-trending")!
            try FileManager.default.createDirectory(at: trendingDirectory, withIntermediateDirectories: true, attributes: nil)
            
            let searchDirectory = URL(string: cacheDirectory.absoluteString + "/giphy-cache-search")!
            try FileManager.default.createDirectory(at: searchDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error)
        }
    }
    
    private func url(by type: AMGiphyCacheType) -> URL {
        switch type {
        case .trending:
            return trendingDirectory
        case .search:
            return searchDirectory
        }
    }
    
    func dataCached(_ id: String, type: AMGiphyCacheType) -> Bool {
        let path = "\(url(by: type).absoluteString)/\(id)"
        return FileManager.default.fileExists(atPath: path)
    }
    
    func saveData(_ id: String, data: Data, type: AMGiphyCacheType) {
        let path = "\(url(by: type).absoluteString)/\(id)"
        FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
    }
    
    func getData(_ id: String, type: AMGiphyCacheType) -> Data? {
        let path = "\(url(by: type).absoluteString)/\(id)"
        return FileManager.default.contents(atPath: path)
    }
    
    func cleanCache(_ type: AMGiphyCacheType) {
        let cacheUrl = url(by: type)
        try? FileManager.default.removeItem(at: cacheUrl)
    }
}
