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
    
    private var configuration: AMGiphyPickerConfiguration = AMGiphyPickerConfiguration.defaultConfiguration
    private let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: AMGiphyGridLayout())
    
    private var dataProvider: AMGiphyDataProvider!
    
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
    
    convenience init(configuration: AMGiphyPickerConfiguration) {
        self.init(frame: .zero)
        self.configuration = configuration
        initialize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
    }
    
    private func initialize() {
        dataProvider = AMGiphyDataProvider(self.configuration)
        
        setupCollectionView()
        loadData()
    }
    
    private func loadData() {
        isLoading = true
        dataProvider.loadGiphy {[weak self] (items) in
            self?.isLoading = false
            self?.giphy = items.map { return AMGiphyViewModel.init($0) }
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
    private func loadNext() {
        if isLoading { return }
        isLoading = true
        dataProvider.loadGiphy(nil, offset: giphy.count) {[weak self] (items) in
            if items.count == 0 { return }
            let viewModels = items.map { return AMGiphyViewModel.init($0) }
            self?.giphy.append(contentsOf: viewModels)
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
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        giphy[indexPath.item].stopFetching()
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if collectionView.contentOffset.x + collectionView.bounds.width + 100 > collectionView.contentSize.width {
            loadNext()
        }
    }
}

extension AMGiphyPicker: AMGiphyGridLayoutDelegate {
    
    func numberOfRows(_ collectionView: UICollectionView) -> Int {
        return configuration.numberRows
    }
    
    func collectionView(_ collectionView: UICollectionView, widthForItemAt indexPath: IndexPath, withHeight height: CGFloat) -> CGFloat {
        let itemSize = giphy[indexPath.item].gifItem.size
        
        let ratio = height/itemSize.height
        return itemSize.width*ratio
    }
}
