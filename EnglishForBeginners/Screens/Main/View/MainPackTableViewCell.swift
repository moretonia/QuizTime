//
//  MainPackTableViewCell.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 19/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit
import PureLayout

protocol MainPackCellDelegate: class {
    func buy(cell: MainPackTableViewCell)
    func timeIsGone(cell: MainPackTableViewCell)
}

class MainPackTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var labelFirstTheme: UILabel!
    @IBOutlet weak var labelSecondTheme: UILabel!
    @IBOutlet weak var labelThirdTheme: UILabel!
    @IBOutlet weak var labelPackInfo: UILabel!
    @IBOutlet weak var labelRemainingTime: UILabel!
    @IBOutlet weak var labelBuy: UILabel!
    @IBOutlet weak var labelOldPrice: UILabel!
    @IBOutlet weak var csOldPriceWidth: NSLayoutConstraint!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    var timer: Timer?
    
    let interval: TimeInterval = 4.0
    
    weak var delegate: MainPackCellDelegate?
    
    var images = [UIImage]()
    
    var onTimerTick: (() -> ())?
    
    var needToCountRemainingTime: Bool = true
    
    var removingDate: Date?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register(MainPackCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: MainPackCollectionViewCell.self))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if window == nil {
            needToCountRemainingTime = false
            stopCellsChanging()
            onTimerTick = nil
        } else {
            needToCountRemainingTime = true
            startCellsChanging()
            onTimerTick = { [weak self] in
                self?.preparePackTimer()
            }
            
            preparePackTimer()
        }
    }
    
    func update(with themeNames: [String], images: [UIImage], price: String, sumPrice: String, removingDate: Date) {
        self.removingDate = removingDate
        
        setLabels(with: themeNames, price: price, sumPrice: sumPrice)
        self.images = images
        
        if onTimerTick == nil {
            onTimerTick = { [weak self] in
                self?.preparePackTimer()
            }
            
            preparePackTimer()
        }
        
        collectionView.reloadData()
    }
    
    private func setLabels(with themeNames: [String], price: String, sumPrice: String) {
        
        labelFirstTheme.text = themeNames[0]
        labelSecondTheme.text = themeNames[1]
        labelThirdTheme.text = themeNames[2]
        
        labelPackInfo.text = "main-pack-info".localizedWithCurrentLanguage()
        labelBuy.text = "main-buy-button".localizedWithCurrentLanguage() + " " + price
        
        let width = sumPrice.or_estimatedSize(font: UIFont.systemFont(ofSize: 17 * 0.6, weight: .medium)).width + 3
        csOldPriceWidth.constant = width
        
        let oldPriceAttributedString = NSAttributedString(string: sumPrice, attributes: [NSAttributedString.Key.strikethroughStyle : 1])
        
        labelOldPrice.attributedText = oldPriceAttributedString
    }
    
    // MARK: - Timers
    
    private func startCellsChanging() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
        }
    }
    
    private func stopCellsChanging() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func onTimer() {
        let currentPoint = CGPoint(x: self.collectionView.center.x + self.collectionView.contentOffset.x, y: self.collectionView.center.y + self.collectionView.contentOffset.y)
        
        guard let currentCellIndex = collectionView.indexPathForItem(at: currentPoint) else {
            return
        }
        
        let nextCellIndex = IndexPath(row: collectionView.numberOfItems(inSection: 0) > currentCellIndex.row + 1 ? currentCellIndex.row + 1 : 0, section: currentCellIndex.section)
        
        collectionView.scrollToItem(at: nextCellIndex, at: .centeredHorizontally, animated: true)
        pageControl.currentPage = nextCellIndex.row
    }
    
    private func preparePackTimer() {
        
        guard let removingDate = removingDate else {
            onTimerTick = nil
            return
        }
        
        let currentDate = Date().timeIntervalSince1970
    
        let remainingLifeTime = removingDate.timeIntervalSince1970 - currentDate
        let remainingLifeTimeString = remainingLifeTime.or_durationStringShortWithSeconds()
        
        DispatchQueue.main.async {
            self.labelRemainingTime.text = remainingLifeTimeString
        }
        
        if remainingLifeTime > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.onTimerTick?()
            }
            return
        } else {
            onTimerTick = nil
            delegate?.timeIsGone(cell: self)
        }
    }

    
    // MARK: - Actions
    
    @IBAction func buy(_ sender: Any) {
        delegate?.buy(cell: self)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MainPackCollectionViewCell.self), for: indexPath) as! MainPackCollectionViewCell
        
        cell.update(image: images[indexPath.row])
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        startCellsChanging()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopCellsChanging()
    }
}


class MainPackCollectionViewCell: UICollectionViewCell {
    
    weak var imageView: UIImageView!
    
    override var reuseIdentifier: String? {
        return "MainPackCollectionViewCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setImageViewIfNeeded() {
        if imageView == nil {
            
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            addSubview(imageView)
            
            imageView.autoPinEdgesToSuperviewEdges()
            
            self.imageView = imageView
        }
    }
    
    func update(image: UIImage) {
        setImageViewIfNeeded()
        
        imageView.image = image
    }
    
}

