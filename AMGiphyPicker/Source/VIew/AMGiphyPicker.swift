//
//  AMGiphyComponent.swift
//  Cadence
//
//  Created by Alexander Momotiuk on 09.01.18.
//  Copyright © 2018 Cadence. All rights reserved.
//

import UIKit
import GiphyCoreSDK

class AMGiphyPicker: UIView {
    
    private var settings: AMGiphyPickerSettings = AMGiphyPickerSettings.defaultSettings
    private let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: AMGiphyGridLayout())
    
    private let dataProvider = AMGiphyDataProvider()
    
    public private(set) var giphy: [AMGiphyViewModel] = []
    private var isLoading = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    convenience init(settings: AMGiphyPickerSettings) {
        self.init(frame: .zero)
        self.settings = settings
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }
    
    private func initialize() {
        setupCollectionView()
        isLoading = true
        dataProvider.loadGiphy {[weak self] (items) in
            self?.isLoading = false
            self?.giphy = AMGiphyPicker.convertModels(items)
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
    private func loadNext() {
        if isLoading { return }
        isLoading = true
        dataProvider.loadGiphy(nil, offset: giphy.count) {[weak self] (items) in
            self?.giphy.append(contentsOf: AMGiphyPicker.convertModels(items))
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                self?.isLoading = false
            }
        }
    }
    
    private func setupCollectionView() {
        addSubview(collectionView)
        (collectionView.collectionViewLayout as! AMGiphyGridLayout).delegate = self
        
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.register(AMGiphyCell.self, forCellWithReuseIdentifier: String(describing: AMGiphyCell.self))
        collectionView.reloadData()
    }
    
    private static func convertModels(_ items: [AMGiphyItem]) -> [AMGiphyViewModel] {
        let result = items.map { (item) -> AMGiphyViewModel in
            return AMGiphyViewModel(item)
        }
        return result
    }
}

extension AMGiphyPicker: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return giphy.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AMGiphyCell.self), for: indexPath) as! AMGiphyCell
        cell.setupWith(giphy[indexPath.row])
        return cell
    }
}

extension AMGiphyPicker: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            giphy[indexPath.row].prefetchData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            giphy[indexPath.row].cancelPrefecth()
        }
    }
}

extension AMGiphyPicker: UICollectionViewDelegate {
    
}

extension AMGiphyPicker: AMGiphyGridLayoutDelegate {
    
    func numberOfRows(_ collectionView: UICollectionView) -> Int {
        return settings.numberRows
    }
    
    func collectionView(_ collectionView: UICollectionView, widthForItemAt indexPath: IndexPath, withHeight height: CGFloat) -> CGFloat {
        let itemSize = giphy[indexPath.item].gifItem.size
        
        if itemSize.height > height {
            let ratio = itemSize.height/height
            return itemSize.width/ratio
        } else if itemSize.height < height {
            let ratio = height/itemSize.height
            return itemSize.width*ratio
        }
        return height
    }
}











