//
//  MainVC.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 27/02/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit
import ORCommonCode_Swift
import AdColony

struct PackInfo {
    var pack: ThemesPack
    var price: String
    var oldPrice: String
    var images: [UIImage]
    var localizableThemeNames: [String]
}

class MainVC: BaseVC, UITableViewDataSource, UITableViewDelegate, MainTableViewCellDelegate, MainPackCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonReloadPack: UIButton!
    @IBOutlet weak var titleLabel: LocalizableLabel!    
    
    var packInfo: PackInfo?
    
    var themes = [Theme]() {
        didSet {
            tableView.reloadData()
        }
    }

    var productsInfo = [ProductInfo]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        AnalyticsHelper.logEventWithParameters(event: .ME_Mainscreen_Opened)
        
        buttonReloadPack.isHidden = !isDebug
        
        prepareNotifications()
        prepareData()
        
        tableView.or_registerCellNib(forClass: MainPackTableViewCell.self)
        tableView.isExclusiveTouch = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateDataFromICloud { (finished) in
            if finished {
                ICloudSynchronizer.synchronizeWithICloud()
            }
        }
        
        titleLabel.text = "themes".localizedWithCurrentLanguage()
       // titleLabel.text = "themes".localized(NativeLanguage.english.currentLocale)
    }
    
    deinit {
        or_removeObserver(self, name: Notifications.iApProductsFetched)
        or_removeObserver(self, name: Notifications.iApProductPurchased)
        or_removeObserver(self, name: Notifications.languageDidChange)
    }
    
    // MARK: -
    
    private func setupPack() {
        
        PackGenerator.getOrGeneratePack { [weak self] (pack) in
            guard let sself = self else {
                return
            }
            
            guard let pack = pack else {
                sself.packInfo = nil
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                return
            }
            
            self?.preparePackInfo(with: pack)
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    private func preparePackInfo(with pack: ThemesPack) {
        let packThemes = themes.filter { (theme) -> Bool in
            var isSelectedTheme = false
            
            for name in pack.themesNames {
                isSelectedTheme = theme.name == name || isSelectedTheme
            }
            
            return isSelectedTheme
        }
        
        let localizableThemeNames = packThemes.map { (theme) -> String in
            return theme.nativeWord?.word ?? ""
        }
        
        var images = [UIImage]()
        
        for theme in packThemes {
            
            guard let imageName = theme.imageName, let image = UIImage(named: imageName) else {
                continue
            }
            
            images.append(image)
        }
        
        if images.count < 3 || localizableThemeNames.count < 3 {
            packInfo = nil
            return
        }
        
        let packPurchaseInfo = productsInfo.filter({ (info) -> Bool in
            return info.themeName == nil
        }).first
        
        let purchaseInfo = productsInfo.filter { (info) -> Bool in
            return info.themeName != nil
            }.first
        
        if packPurchaseInfo == nil || purchaseInfo == nil {
            self.packInfo = nil
            return
        }
        
        packInfo = PackInfo(pack: pack, price: packPurchaseInfo?.priceWithCurrency ?? "", oldPrice: purchaseInfo?.triplePriceWithCurrency ?? "", images: images, localizableThemeNames: localizableThemeNames)
    }
    
    private func prepareNotifications() {
        or_addObserver(self, selector: #selector(productsWasFetched(_:)), name: Notifications.iApProductsFetched)
        or_addObserver(self, selector: #selector(productWasPurchased(_:)), name: Notifications.iApProductPurchased)
        or_addObserver(self, selector: #selector(languageDidChange), name: Notifications.languageDidChange)
    }
    
    private func prepareData() {
        ThemeManager.themeListFromAsset { [weak self] (themes) in
            guard let sself = self, let themes = themes else {
                return
            }
            
            sself.themes = themes
            sself.updateDataFromICloud(ignoreErrors: false, completion: nil)
        }
    }
    
    private func removeCurrentPack() {
        PackGenerator.removeCurrentPack()
        packInfo = nil
        tableView.reloadData()
    }
    
    private func updateDataFromICloud(ignoreErrors: Bool = true, completion: ((Bool) -> ())?) {
        IAPHandler.shared.fetchAvailableProducts()
        
        ThemeManager.updateThemesFromICloud(completion: { [weak self] (themes) in
            guard let themes = themes else {
                print("Some errors when tried to get themes")
                completion?(false)
                return
            }
            
            guard let sself = self else {
                completion?(false)
                return
            }
            
            sself.themes = themes
            completion?(true)
        }, errorHandler: { [weak self] (error) in
            guard let sself = self else {
                return
            }
            DispatchQueue.main.async {
                sself.tableView.reloadData()
                completion?(false)
                if !ignoreErrors {
                    ErrorPopupHelper.showError(error as NSError, title: "iCloud error", parentVC: sself)
                }
            }
        })
    }
    
    // MARK: - Notifications
    
    @objc func productsWasFetched(_ notification: NSNotification) {
        guard let productsInfo = notification.userInfo?[Constants.purchasesInfo] as? [ProductInfo] else {
            return
        }
        
        self.productsInfo = productsInfo
        
        if packInfo == nil {
            setupPack()
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
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
        
        var themesName = [String]()
        
        for productInfo in productsInfo {
            if let themeName = productInfo.themeName {
                themesName.append(themeName)
            } else {
                themesName.append(contentsOf: packInfo?.pack.themesNames ?? [])
            }
        }
        
        if status == .purchased || status == .restored {
            ICloudSaver.themesPurchased(themesNames: themesName) { (unsavedThemesNames) in
                ProfileManager.saveUnsynchronizedPurchases(themeNames: unsavedThemesNames)
            }
        }

        removeCurrentPack()
        
        ThemeManager.buyThemes(themesName) { [weak self] in
            guard let sself = self else {
                return
            }
            
            sself.tableView.reloadData()
        }
    }
    
    @objc func languageDidChange() {
        VocabularyManager.removeAllNativeWords {
            DispatchQueue.main.async {
                ThemeManager.themeList(completion: { [weak self](themes) in
                    guard let sself = self else {
                        return
                    }
                    
                    if let packInfo = sself.packInfo {
                        sself.preparePackInfo(with: packInfo.pack)
                    }
                    
                    sself.themes = themes ?? []
                    sself.tableView.reloadData()
                })
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return packInfo == nil ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if packInfo == nil {
            return themes.count
        }
        
        return section == 0 ? 1 : themes.count
    }
    
    fileprivate func prepareCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0, let packInfo = packInfo {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MainPackTableViewCell.self), for: indexPath) as! MainPackTableViewCell
            
            cell.update(with: packInfo.localizableThemeNames, images: packInfo.images, price: packInfo.price, sumPrice: packInfo.oldPrice, removingDate: packInfo.pack.removingDate)
            
            cell.delegate = self
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "themeCell", for: indexPath) as! MainTableViewCell
        let theme = themes[indexPath.row]
        cell.cellState(opened: theme.opened)
        cell.themeLabel.text = theme.nativeWord?.word ?? theme.name
        cell.topicsCountLabel.text = "topics-count".localizedWithCurrentLanguage()
        if let imageName = theme.imageName {
            cell.themeImage.image = UIImage(named: imageName)
        }
        
        if !theme.opened {
            let index = productsInfo.firstIndex { (productInfo) -> Bool in
                return productInfo.themeName == theme.name
            }
            
            if let strongIndex = index {
                cell.updatePrice(productsInfo[strongIndex].priceWithCurrency)
            }
        }
        
        cell.delegate = self
        
        let starType = ThemeManager.starType(of: theme)
        
        cell.updateStarAndProgress(theme.starsCount, starType: starType, examPassed: theme.passed)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = prepareCell(tableView, indexPath)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0, packInfo != nil {
            return 240.0
        }
        
        let height = tableView.frame.width * 0.75
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let themeName = themes[indexPath.row].name!
        showTopicsScreen(with: themeName)
    }
    
    // MARK: - MainTableViewCellDelegate
    
    func buyButtonPressed(in cell: MainTableViewCell) {
        guard let index = tableView.indexPath(for: cell)?.row, let themeName = themes[index].name else {
            return
        }
        showActivityIndicator()
        IAPHandler.shared.purchaseTheme(with: themeName)
    }
    
    func studyButtonPressed(in cell: MainTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let themeName = themes[indexPath.row].name!
        showTopicsScreen(with: themeName)
    }
    
    func fakePurchasePressed(in cell: MainTableViewCell) {
        guard let index = tableView.indexPath(for: cell)?.row else {
            return
        }
        
        buySelectedTheme(themes[index]) { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    // MARK: - Navigation
    
    func showTopicsScreen(with themeName: String) {
        showActivityIndicator()
        ThemeManager.theme(with: themeName) { [weak self] (theme) in
            guard let sself = self else {
                return
            }
            
            guard let theme = theme else {
                return
            }
            
            let topicsVC = VCEnum.topics.vc as! TopicsViewController
            
            topicsVC.theme = theme
            topicsVC.productInfo = sself.productsInfo.first(where: { (productInfo) -> Bool in
                productInfo.themeName == themeName
            })
            
            ICloudSaver.createThemeIfNeeded(themeName: themeName, completion: { (created) in
                if theme.needToUpdateStarsFromICloud || created {
                    ThemeManager.updateStarsFromICloud(themeName: theme.name!, completion: {(error) in
                        DispatchQueue.main.async {
                            sself.hideActivityIndicator()

                            sself.show(topicsVC, sender: nil)
                        }
                    })
                } else {
                    DispatchQueue.main.async {
                        sself.hideActivityIndicator()
                        sself.show(topicsVC, sender: nil)
                    }
                }
            })
        }
    }
    
    @IBAction func profilePressed(_ sender: Any) {
        let profileVC = VCEnum.profile.vc
        
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    // TEMP
    
    @IBAction func reloadPack(_ sender: Any) {
        PackGenerator.removeCurrentPack()
        UserDefaultsManager.shared.currentThemesPackRemovingTime = nil
        
        setupPack()
    }
    // MARK: - MainPackCellDelegate
    
    func buy(cell: MainPackTableViewCell) {
        showActivityIndicator()
        IAPHandler.shared.buyPack()
    }
    
    func timeIsGone(cell: MainPackTableViewCell) {
        removeCurrentPack()
    }
}

