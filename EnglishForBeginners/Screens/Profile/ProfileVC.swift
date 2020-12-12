//
//  ProfileVC.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 03/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit
import ORCommonCode_Swift
import StoreKit

class ProfileVC: BaseVC, UITableViewDelegate, UITableViewDataSource, SKStoreProductViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!    
    @IBOutlet weak var titleLabel: LocalizableLabel!
    
    private var sharer = FBSharer()
    
    private var starsInfo = [StarsInfo]()
    
    var sections: [ProfileSectionType] = [.experience, .skill, .global, .local]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AnalyticsHelper.logEventWithParameters(event: .ME_Profile_Opened)
        
        or_addObserver(self, selector: #selector(productWasPurchased(_:)), name: Notifications.iApProductPurchased)
        
        prepareTableView()
        prepareDataFromICloudIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        titleLabel.text = "profile".localizedWithCurrentLanguage()
    }
    
    deinit {
        or_removeObserver(self, name: nil)
    }
    
    // MARK: - iCloud
    
    private func prepareDataFromICloudIfNeeded() {
        ICloudProvider.experience { [weak self] (experience) in
            ProfileManager.saveExperience(experience: experience, difference: 0) {
                self?.tableView.reloadRows(at: [IndexPath.init(row: 0, section: ProfileSectionType.experience.rawValue)], with: .automatic)
            }
        }
        
        ICloudProvider.starsInfo { [weak self] (starsInfo, error) in
            guard let sself = self else {
                return
            }
            guard error == nil else {
//                ErrorPopupHelper.showError(error! as NSError, title: "iCloud error", parentVC: sself)
                ProfileManager.removeStarsFromProfile {
                    DispatchQueue.main.async {
                        sself.tableView.reloadSections(IndexSet(integer: ProfileSectionType.skill.rawValue), with: .automatic)
                    }
                }
                
                return
            }
            ProfileManager.saveStarsCount(starsInfo: starsInfo, completion: {
                DispatchQueue.main.async {
                    sself.tableView.reloadSections(IndexSet(integer: ProfileSectionType.skill.rawValue), with: .automatic)
                }
            })
        }
    }
    
    // MARK: - Notifications
    
    @objc func productWasPurchased(_ notification: NSNotification) {
        guard let status = notification.userInfo?[Constants.purchaseStatus] as? IAPHandlerAlertType else {
            return
        }
        
        ThemeManager.updateThemesFromICloud(completion: { [weak self] (_) in
            self?.hideActivityIndicator()
            
            self?.or_showAlert(title: "Purchases", message: status.message())
        }) { [weak self] (error) in
            
            self?.hideActivityIndicator()
        
            self?.or_showAlert(title: "Purchases", message: error.localizedDescription)
        }
    }
    
    // MARK: -
    
    func prepareTableView() {
        tableView.or_registerCellNib(forClass: ProfileExperienceCell.self)
        tableView.or_registerCellNib(forClass: ProfileSkillCell.self)
        tableView.or_registerCellNib(forClass: ProfileOtherCell.self)
        tableView.or_registerHeaderFooterNib(forClass: ProfileHeaderView.self)
    }
    
    func starsCount(for lessonType: LessonType) -> Int {
        let starsCount = LearningProgressManager.numberOfStarsFor(lessonType: lessonType)

        let iCloudStarsCount = ProfileManager.starsCount(for: lessonType)
        
        return starsCount > iCloudStarsCount ? starsCount : iCloudStarsCount
    }
    
    fileprivate func setupSkillCell(_ tableView: UITableView, _ indexPath: IndexPath) -> ProfileSkillCell {
        let skillCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProfileSkillCell.self), for: indexPath) as! ProfileSkillCell
        
        let lessonType = LessonType.types[indexPath.row]
        
        let maximumCount = LearningProgressManager.maximumNumberOfStarsForLessonType()
        let starsCount = self.starsCount(for: lessonType)
        let progress = CGFloat(starsCount) / CGFloat(maximumCount)
        
        skillCell.update(with: lessonType.title, points: starsCount, progress: progress)
        
        return skillCell
    }
    
    fileprivate func setupGlobalCell(_ tableView: UITableView, _ indexPath: IndexPath, _ currentSection: ProfileSectionType) -> ProfileOtherCell {
        let globalCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProfileOtherCell.self), for: indexPath) as! ProfileOtherCell
        
        let cellType = currentSection.otherCellTypes[indexPath.row]
        
        globalCell.update(with: cellType.image, title: cellType.title)
        globalCell.imageViewCorner.isHidden = true
        
        if indexPath.row == currentSection.cellNumber - 1 {
            globalCell.setupSeparatorsVisibility(top: true, bottom: true)
        } else {
            globalCell.setupSeparatorsVisibility()
        }
        
        return globalCell
    }
    
    fileprivate func setupLocalCell(_ tableview: UITableView, _ indexPath: IndexPath, _ currentSection: ProfileSectionType) -> ProfileOtherCell  {
        let localCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProfileOtherCell.self), for: indexPath) as! ProfileOtherCell
        
        let cellType = currentSection.otherCellTypes[indexPath.row]
        
        var image = cellType.image
        
        if cellType == .language {
            if let language = UserDefaultsManager.shared.userLanguage, let flagImage = NativeLanguage(rawValue: language)?.smallImage {
                image = flagImage
            }
        }
        
        localCell.update(with: image, title: cellType.title)
        localCell.imageViewCorner.isHidden = false
        
        if indexPath.row == 0 {
            localCell.setupSeparatorsVisibility(top: false, bottom: false)
        } else {
            localCell.setupSeparatorsVisibility()
        }
        
        return localCell
    }
    
    
    // MARK: - Action operations
    
    func shareAppInfo() {
        let experience = ProfileManager.getOverallExperience()
        let rank = RankCalculator(experience: experience)
        
        FBSharer().shareUserResults(fromVC: self, link: URL(string: "https://itunes.apple.com/gb/app/learn-model-english/id1367918761?mt=8"), quote: String(format: "experience-and-rank-share".localizedWithCurrentLanguage(), experience, rank.rank.title.capitalized) )
        // changed ru to gb on 21/7/19
    }
    
    func rateApp() {
        let storeViewController = SKStoreProductViewController()
        
        storeViewController.delegate = self
        storeViewController.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier : "1367918761"], completionBlock: nil)
        
        present(storeViewController, animated: true, completion: nil)
    }
    
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cellNumber
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentSection = sections[indexPath.section]
        
        var cell: UITableViewCell
        
        switch currentSection {
        case .experience:
            let experienceCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProfileExperienceCell.self), for: indexPath) as! ProfileExperienceCell
            let experience = ProfileManager.getOverallExperience()
            let rankCalculator = RankCalculator(experience: experience)
            experienceCell.update(with: rankCalculator)
            cell = experienceCell
        case .skill:
            cell = setupSkillCell(tableView, indexPath)
        case .global:
            cell = setupGlobalCell(tableView, indexPath, currentSection)
        case .local:
            cell = setupLocalCell(tableView, indexPath, currentSection)
        }
        
        cell.backgroundColor = currentSection.backgroundColor
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let currentSection = sections[section]
        
        if !currentSection.isHeaderExist {
            let view = UIView()
            view.backgroundColor = currentSection.backgroundColor
            
            return view
        }
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: ProfileHeaderView.self)) as! ProfileHeaderView
        headerView.changeContentColor(currentSection.headerContentColor)
        headerView.contentView.backgroundColor = currentSection.backgroundColor
        headerView.setType(currentSection)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let currentSection = sections[section]
        let footer = UIView()
        
        footer.backgroundColor = currentSection.backgroundColor
        
        return footer
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentSection = sections[indexPath.section]
        
        switch currentSection {
        case .global, .local:
            let cellType = currentSection.otherCellTypes[indexPath.row]
            
            switch cellType {
            case .share:
                shareAppInfo()
                AnalyticsHelper.logEventWithParameters(event: .Profile_Share_Produced)
            case .language:
                show(VCEnum.language.vc, sender: nil)
            case .restore:
                AnalyticsHelper.logEventWithParameters(event: .Profile_Purchases_Restored)
                IAPHandler.shared.restorePurchase()
                showActivityIndicator()
            case .rate:
                AnalyticsHelper.logEventWithParameters(event: .Profile_Rate_Restored)
                rateApp()
            case .leaderboard:
                AnalyticsHelper.logEventWithParameters(event: .Profile_Leaderboard_Opened)
                let score = Int64(ProfileManager.getOverallExperience())
                showActivityIndicator()
                GameCenter.shared.showLeaderboard(score: score, from: self) { [weak self] success, error in
                    guard let sself = self else {
                        return
                    }
                    sself.hideActivityIndicator()
                    if let error = error as NSError? {
                        //TODO: add locale
                        let message = error.code == AppErrorCode.requestTimedOut.rawValue ? error.localizedDescription : "error-load-leaderboard".localizedWithCurrentLanguage()
                        sself.or_showAlert(title: "error".localizedWithCurrentLanguage(), message: message)
                    }
                }
            case .about:
                AnalyticsHelper.logEventWithParameters(event: .Profile_AboutUs_Opened)
                show(VCEnum.about.vc, sender: nil)
            case .removeICloudInfo:
                showActivityIndicator()
                ICloudSaver.removeAllThemes { (error) in
                    self.hideActivityIndicator()
                }
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sections[indexPath.section].cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let currentSection = sections[section]
        
        return currentSection.isHeaderExist ? sections[section].headerHeight : 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sections[section].footerHeight
    }
    
    // MARK: - SKStoreProductViewControllerDelegate
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    @IBAction func close(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
