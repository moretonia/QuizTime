//
//  DictionaryDetailVC.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 12/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit
import ISPageControl
import iCarousel

class DictionaryDetailVC: BaseVC, iCarouselDelegate, iCarouselDataSource, DictionaryDetailCellDelegate {

    @IBOutlet weak var pageControl: ISPageControl!
    @IBOutlet weak var carouselView: iCarousel!
    
    var speechSynthesizer = SpeechSynthesizer()
    
    var cellSize: CGSize {
        return CGSize(width: carouselView.frame.width * 0.75, height: carouselView.frame.height)
    }
    
    var words = [VocabularyItem]()
    var selectedIndex: Int?
    var lastPronouncedWordIndex: Int!
    
    let cellSpacing: CGFloat = 1.1
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        carouselView.isPagingEnabled = true
        
        setupPageControl()
        
        if let selectedIndex = selectedIndex {
            speakWord(with: selectedIndex)
        }
        
        view.layoutIfNeeded()
        
        carouselView.currentItemIndex = selectedIndex ?? 0
        carouselView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: -
    
    private func setupPageControl() {
        pageControl.numberOfPages = words.count
        pageControl.currentPageTintColor = AppColors.currentPageControlItem
        pageControl.inactiveTintColor = AppColors.pageControlItems
        
        if let selectedIndex = selectedIndex {
            pageControl.currentPage = selectedIndex
        }
    }
    
    // MARK: - Speech
    
    func speakCurrentWordIfNeeded() {
        let visibleIndex = carouselView.currentItemIndex
        
        if visibleIndex != lastPronouncedWordIndex {
            speakWord(with: visibleIndex)
        }
    }
    
    func speakWord(with index: Int) {
        speak(words[index].word)
        lastPronouncedWordIndex = index
    }
    
    func speak(_ word: String?) {
        guard let wordString = word else {
            return
        }
        
        speechSynthesizer.speak(wordString)
    }
    
    // MARK: - Actions
    
    @IBAction func closePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - iCarouselDataSource
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return words.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var dictionaryDetailCell: DictionaryDetailCell
        if view == nil {
            dictionaryDetailCell = DictionaryDetailCell.or_loadFromNib() 
        } else {
            dictionaryDetailCell = view as! DictionaryDetailCell
        }
        
        dictionaryDetailCell.delegate = self
        dictionaryDetailCell.update(with: words[index])
        dictionaryDetailCell.updatePageNumber(index + 1)
        dictionaryDetailCell.frame.size = cellSize
        
        return dictionaryDetailCell
    }
    
    // MARK: - iCarouselDelegate
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch option {
        case .wrap:
            return 1.0
        case .spacing:
            return cellSpacing
        case .fadeMax:
            return 0.0
        case .fadeMin:
            return 0.0
        case .fadeMinAlpha:
            return 0.5
        default:
            return value
        }
    }
    
    func carouselItemWidth(_ carousel: iCarousel) -> CGFloat {
        return cellSize.width
    }
    
    func carouselDidScroll(_ carousel: iCarousel) {

    }
    
    func carouselDidEndDecelerating(_ carousel: iCarousel) {
        speakCurrentWordIfNeeded()
        
        pageControl.currentPage = carousel.currentItemIndex
    }
    
    func carouselDidEndDragging(_ carousel: iCarousel, willDecelerate decelerate: Bool) {
        speakCurrentWordIfNeeded()
        
        pageControl.currentPage = carousel.currentItemIndex
    }
    
    // MARK: - DictionaryDetailCVCellDelegate
    
    func speakButtonPressed(dictionaryDetailCVCell: DictionaryDetailCell) {
        let index = carouselView.index(ofItemView: dictionaryDetailCVCell)
        speakWord(with: index)
    }
}
