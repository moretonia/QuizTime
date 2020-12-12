//
//  TopicsViewController.swift
//  EnglishForBeginners
//
//  Created by Vladimir on 28.02.18.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit
import ORCommonUI_Swift
import ORCommonCode_Swift

class TopicsViewController: BaseVC, UICollectionViewDelegate,
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TopicsCVCellDelegate, ThemeExamCVCellDelegate {
    
    @IBOutlet weak var topicsPageControl: UIPageControl!
    @IBOutlet weak var topicsCollectionView: UICollectionView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var labelThemeName: UILabel!
    @IBOutlet weak var buttonBuy: ORRoundRectButton!
    
    var topicsCountWithExam: Int {
        return topics.count == 0 ? 0 : topics.count + 1
    }

    var isOpened: Bool = false {
        didSet {
            buttonBuy.isHidden = isOpened
        }
    }
    
    var theme: Theme!
    var topics = [Topic]()
    var productInfo: ProductInfo?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareCollectionView()
        prepareBuyButton()
        
        prepareNotifications()
        updateView()
        
        AnalyticsHelper.logEventWithParameters(event: .ME_Theme_Opened, themeId: theme.name!, topicId: nil, typeOfLesson: nil, starsCount: nil, language: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        topicsCollectionView.reloadData()
    }
    
    deinit {
        or_removeObserver(self, name: Notifications.iApProductsFetched)
        or_removeObserver(self, name: Notifications.iApProductPurchased)
    }
    
    // MARK: -
    
    private func prepareBuyButton() {
        buttonBuy.titleLabel?.adjustsFontSizeToFitWidth = true
        buttonBuy.titleLabel?.numberOfLines = 1
        buttonBuy.titleLabel?.lineBreakMode = .byClipping
        
        buttonBuy.alpha = 1.0
        buttonBuy.isUserInteractionEnabled = true
        
        if let priceWithCurrency = productInfo?.priceWithCurrency {
            buttonBuy.setTitle("buy-theme".localizedWithCurrentLanguage() + " \(priceWithCurrency)", for: .normal)
        } else {
            buttonBuy.setTitle("main-buy-button".localizedWithCurrentLanguage(), for: .normal)
            buttonBuy.alpha = 0.8
            buttonBuy.isUserInteractionEnabled = false
        }
    }
    
    private func prepareNotifications() {
        or_addObserver(self, selector: #selector(productsWasFetched(_:)), name: Notifications.iApProductsFetched)
        or_addObserver(self, selector: #selector(productWasPurchased(_:)), name: Notifications.iApProductPurchased)
    }

    func prepareCollectionView() {
        
        topicsCollectionView.allowsSelection = false
        automaticallyAdjustsScrollViewInsets = false
        
        topicsCollectionView.or_registerCellNib(forClass: TopicsCVCell.self)
        topicsCollectionView.or_registerCellNib(forClass: ThemeExamCVCell.self)
    }
    
    func updateView() {
        labelThemeName.text = theme.nativeWord?.word
        topics = theme.convertedTopics
        isOpened = theme.opened
        topicsCollectionView.reloadData()
    }
    
    // MARK: - Notifications
    
    @objc func productsWasFetched(_ notification: NSNotification) {
        guard let productsInfo = notification.userInfo?[Constants.purchasesInfo] as? [ProductInfo] else {
            return
        }
        
        self.productInfo = productsInfo.filter({ (productInfo) -> Bool in
            return productInfo.themeName == theme.name
        }).first
        
        DispatchQueue.main.async {
            self.prepareBuyButton()
        }
        
        
    }
    
    @objc func productWasPurchased(_ notification: NSNotification) {
        defer {
            hideActivityIndicator()
        }
        
        guard let productsInfo = notification.userInfo?[Constants.purchasesInfo] as? [ProductInfo], let status = notification.userInfo?[Constants.purchaseStatus] as? IAPHandlerAlertType else {
            return
        }
        
        if status == .disabled || status == .error || status == .failed {
            or_showAlert(title: "Purchases", message: status.message())
            return
        }
        
        let isCurrentThemePurchased = !productsInfo.filter { (productInfo) -> Bool in
            return productInfo.themeName == theme.name
        }.isEmpty
        
        if isCurrentThemePurchased, let themeName = theme.name {
            ThemeManager.buyThemes([themeName]) { [weak self] in
                guard let sself = self else {
                    return
                }
                
                sself.updateView()
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func close(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buyButtonPressed(_ sender: Any) {
        guard let themeName = theme.name else {
            return
        }
        
        showActivityIndicator()
        
        IAPHandler.shared.purchaseTheme(with: themeName)
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        topicsPageControl.numberOfPages = topicsCountWithExam
        return topicsCountWithExam
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let isTopicCell = indexPath.row < topics.count
        
        if isTopicCell {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TopicsCVCell.self),
                                                          for: indexPath) as! TopicsCVCell
            
            let topic = topics[indexPath.row]
            
            if let imageName = topic.imageName {
                cell.photoView.image = UIImage(named: imageName)
            }
            
            cell.updateTopicName(topic.nativeWord?.word ?? topic.name!)
            cell.changeState(isOpened)

            cell.delegate = self
            return cell
            
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ThemeExamCVCell.self),
                                                          for: indexPath) as! ThemeExamCVCell
            cell.labelExamName.text = String(format: "some-theme-quiz".localizedWithCurrentLanguage(), theme.nativeWord?.word ?? theme.name!)            
            var examStatus: ThemeExamCVCell.ExamState = .notPurchased

            if let theme = theme, isOpened {
                let starType = ThemeManager.starType(of: theme)                
                examStatus = theme.passed ? .passAgain : (starType == .gold ? .opened : .locked)
            }
            
            cell.updateProgress(theme?.starsCount ?? 0)
            
            cell.changeState(examStatus)
            cell.delegate = self
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let isTopicCell = indexPath.row < topics.count
        if isTopicCell, let cell = cell as? TopicsCVCell {
            cell.stars = topics[indexPath.row].starsSet
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let thisWidth = CGFloat(UIScreen.main.bounds.width)
        
        return CGSize(width: thisWidth, height: UIScreen.main.bounds.height)
    }
    
    // MARK: - TopicsCVCellDelegate
    
    func dictionaryPressed(topicsCVCell: TopicsCVCell) {
        guard let index = topicsCollectionView.indexPath(for: topicsCVCell)?.row, index < topics.count else {
            return
        }
        
        let selectedTopic = topics[index]
        
        let dictionaryVC = VCEnum.dictionary.vc as! DictionaryVC
        dictionaryVC.itemsIds = selectedTopic.wordsIds
        dictionaryVC.themeName = theme.name!
        
        AnalyticsHelper.logEventWithParameters(event: .ME_Dictionary_Opened, themeId: theme.name!, topicId: topics[index].name!, typeOfLesson: nil, starsCount: nil, language: nil)
        
        navigationController?.pushViewController(dictionaryVC, animated: true)
    }
    
    func lessonPressed(topicsCVCell: TopicsCVCell, lessonType: LessonType) {
        guard let index = topicsCollectionView.indexPath(for: topicsCVCell)?.row, index < topics.count else {
            return
        }
        
        let selectedTopic = topics[index]
        
        let lessonVC = VCEnum.levels.vc as! LevelsVC
        lessonVC.lessonType = lessonType
        lessonVC.topic = selectedTopic
        
        navigationController?.pushViewController(lessonVC, animated: true)
    }
    
    // MARK: - ThemeExamCVCellDelegate
    
    func examButtonPressed() {
        let examVC = VCEnum.levels.vc as! LevelsVC
        examVC.lessonType = nil
        examVC.theme = theme
        
        navigationController?.pushViewController(examVC, animated: true)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        topicsPageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        topicsPageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
}

