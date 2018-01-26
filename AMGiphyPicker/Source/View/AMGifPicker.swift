//
//  AMGifPicker.swift
//  Cadence
//
//  Created by Alexander Momotiuk on 09.01.18.
//  Copyright © 2018 Cadence. All rights reserved.
//

import UIKit
import GiphyCoreSDK

class AMGifPicker: UIView {
    
    public private(set) var configuration: AMGifPickerConfiguration = AMGifPickerConfiguration(apiKey: "64RLJtsFr7zEXrFbzsAetbduFJU3qpF6")
    
    private let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: AMGifLayout())
    private var model: AMGifPickerModel!
    private var isLoading = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    convenience init(configuration: AMGifPickerConfiguration) {
        self.init(frame: .zero)
        self.configuration = configuration
        initialize()
    }
    
    private func initialize() {
        setupCollectionView()
        
        model = AMGifPickerModel(config: self.configuration)
        model.delegate = self
    }
    
    //MARK: - Layout
    private func setupCollectionView() {
        addSubview(collectionView)
        (collectionView.collectionViewLayout as! AMGifLayout).delegate = self
        
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.register(AMGifCell.self, forCellWithReuseIdentifier: String(describing: AMGifCell.self))
        collectionView.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }
}

extension AMGifPicker: AMGifPickerModelDelegate {
    
    func model(_ model: AMGifPickerModel, didInsert indexPath: [IndexPath]) {
        DispatchQueue.main.async {
            self.collectionView.insertItems(at: indexPath)
        }
    }
    
    func modelDidUpdatedData(_ model: AMGifPickerModel) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

extension AMGifPicker: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AMGifCell.self), for: indexPath) as! AMGifCell
        if let item = model.item(at: indexPath.row) {
            cell.setupWith(item)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        model.item(at: indexPath.row)?.stopFetching()
    }
}

extension AMGifPicker: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            model.item(at: indexPath.row)?.prefetchData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            model.item(at: indexPath.row)?.cancelPrefecth()
        }
    }
}

extension AMGifPicker: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if collectionView.contentOffset.x + collectionView.bounds.width + 100 > collectionView.contentSize.width {
            model.loadNext()
        }
    }
}

extension AMGifPicker: AMGifLayoutDelegate {
    
    func numberOfRows(_ collectionView: UICollectionView) -> Int {
        return configuration.numberRows
    }
    
    func collectionView(_ collectionView: UICollectionView, widthForItemAt indexPath: IndexPath, withHeight height: CGFloat) -> CGFloat {
        guard let itemSize = model.item(at: indexPath.row)?.gifItem.size else {
            return 0
        } 
        let ratio = height/itemSize.height
        return itemSize.width*ratio
    }
}
