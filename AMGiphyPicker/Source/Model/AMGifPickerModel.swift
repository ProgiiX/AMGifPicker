//
//  AMGifPickerModel.swift
//  AMGiphyPicker
//
//  Created by Alexander Momotiuk on 25.01.18.
//  Copyright © 2018 Alexander Momotiuk. All rights reserved.
//

import Foundation

fileprivate struct Configuration {
    static let limit = 40
}

protocol AMGifPickerModelDelegate: class {
    
    func modelDidUpdatedData(_ model: AMGifPickerModel)
}

class AMGifPickerModel {
    
    weak var dlelegate: AMGifPickerModelDelegate?
    
    private var configuration: AMGifPickerConfiguration
    
    private var trendingGifs: Set<AMGifViewModel> = []
    private var searchGifs: Set<AMGifVideModel> = []
    private var searchString: String? = nil
    
    private var provider: AMGifDataProvider
    
    init(config: AMGifPickerConfiguration) {
        configuration = config
        provider = AMGifDataProvider(apiKey: config.apiKey)
        loadData()
    }
}

//MARK: - Private Methods
extension AMGifPickerModel {
    
    private func loadData() {
        provider.loadGiphy(nil, offset: 0, limit: Configuration.limit) {[weak self] (gifs) in
            guard let gifs = gifs, let strongSelf = self else { return }
            strongSelf.trendingGifs = strongSelf.trendingGifs.union(gifs)
            strongSelf.dlelegate?.modelDidUpdatedData(strongSelf)
        }
    }
}

//MARK: - Data Source Methods
extension AMGifPickerModel {
    
    func numberOfItems() -> Int {
        if searchString != nil {
            return searchGifs.count
        }
        return trendingGifs.count
    }
    
    func item(at index: Int) -> AMGifViewModel
}






