//
//  AboutVC.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 18/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit
import ORCommonUI_Swift

class AboutVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let sections: [AboutSectionType] = [.description, .mechanics, .rewards, .copyrights]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.or_registerHeaderFooterNib(forClass: ProfileHeaderView.self)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 0.1))
    }
    
    // MARK: - Actions
    
    @IBAction func back(_ sender: UIButton) {
        popVC()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = sections[section]
        return section.isHeaderExist ? section.headerHeight : 0
    }
    
    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionType = sections[indexPath.section]
        
        switch sectionType {
        case .description:
            return setupDescriptionSection(tableView: tableView, indexPath: indexPath)
        case .mechanics:
            return setupMechanicsSection(tableView: tableView, indexPath: indexPath)
        case .rewards:
            return setupRewardsSection(tableView: tableView, indexPath: indexPath)
        case .copyrights:
            return setupCopyrightSection(tableView: tableView, indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let currentSection = sections[section]
        
        if !currentSection.isHeaderExist {
            let view = UIView()
            view.backgroundColor = currentSection.backgroundColor
            return view
        }
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: ProfileHeaderView.self)) as! ProfileHeaderView
        headerView.changeContentColor(AppColors.profileDefaultHeaderContentColor)
        headerView.contentView.backgroundColor = currentSection.backgroundColor
        headerView.set(icon: #imageLiteral(resourceName: "icon-dots"), title: nil)
        
        return headerView
        
    }
    
    // MARK: - Cells setup
    
    func setupDescriptionSection(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let sectionType: AboutSectionType = .description
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AboutSimpleTextCell.self), for: indexPath) as! AboutSimpleTextCell
        
        let description = "model-english-mission".localizedWithCurrentLanguage() + "\n" + "app-structure".localizedWithCurrentLanguage()

        var attributedString = NSMutableAttributedString(string: description)
        
        attributedString = setupAttributedString(attributedString, textColor: sectionType.textColor)
        
        let range = attributedString.mutableString.range(of: "Model English")
        if range.location != NSNotFound {
            attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 20, weight: .bold), range: range)
            attributedString.addAttribute(.foregroundColor, value: AppColors.aboutBlueColor, range: range)
        }

        let imageRange = attributedString.mutableString.range(of: "_")
        if imageRange.location != NSNotFound {
            let attachment = NSTextAttachment()
            attachment.image = #imageLiteral(resourceName: "icon-about-dictionary")
            
            attributedString.replaceCharacters(in: imageRange, with: NSAttributedString(attachment: attachment))
        }

        
        cell.update(with: attributedString)
        
        cell.backgroundColor = AboutSectionType.description.backgroundColor
        
        return cell
    }
    
    func setupMechanicsSection(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let sectionType: AboutSectionType = .mechanics
        
        guard let rowType = AboutMechanicsType(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        
        if rowType == .description {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AboutSimpleTextCell.self), for: indexPath) as! AboutSimpleTextCell
            
            var attributedString = NSMutableAttributedString(string: rowType.text)
            attributedString = setupAttributedString(attributedString, textColor: sectionType.textColor)
            
            cell.update(with: attributedString)
            
            cell.backgroundColor = sectionType.backgroundColor
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AboutIconWithTitleAndTextCell.self), for: indexPath) as! AboutIconWithTitleAndTextCell
        
        let attributedString = NSMutableAttributedString(string: rowType.text)
        
        cell.update(with: rowType.icon, title: rowType.title ?? "", text: setupAttributedString(attributedString, textColor: .white, firstLineHeadIndent: 0))
        cell.labelTitle.textColor = sectionType.textColor
        cell.labelText.textColor = sectionType.textColor
        
        cell.backgroundColor = AboutSectionType.mechanics.backgroundColor
        
        return cell
    }
    
    func setupRewardsSection(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let sectionType: AboutSectionType = .rewards
        
        guard let rowType = AboutRewardsType(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        
        if rowType == .description {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AboutSimpleTextCell.self), for: indexPath) as! AboutSimpleTextCell
            
            var attributedString = NSMutableAttributedString(string: rowType.text)
            attributedString = setupAttributedString(attributedString, textColor: sectionType.textColor)
            
            let imageRange = attributedString.mutableString.range(of: "_")
            if imageRange.location != NSNotFound {
                let attachment = NSTextAttachment()
                attachment.image = #imageLiteral(resourceName: "icon-profile-small")
                
                attributedString.replaceCharacters(in: imageRange, with: NSAttributedString(attachment: attachment))
            }
            
            cell.update(with: attributedString)
            
            cell.backgroundColor = sectionType.backgroundColor
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AboutIconWithTextCell.self), for: indexPath) as! AboutIconWithTextCell
        
         let attributedString = NSMutableAttributedString(string: rowType.text)
        
        cell.update(with: rowType.icon, text: setupAttributedString(attributedString, textColor: .white, firstLineHeadIndent: 0))
        cell.labelText.textColor = sectionType.textColor
        
        cell.backgroundColor = sectionType.backgroundColor
        
        return cell
    }
    
    func setupCopyrightSection(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let sectionType: AboutSectionType = .copyrights
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AboutCopyrightCell.self), for: indexPath) as! AboutCopyrightCell
        
        let attributedString = NSMutableAttributedString(string: "copyright".localizedWithCurrentLanguage() + "\n" + "design-and-development".localizedWithCurrentLanguage() + "\n"
            +
            "Privacy Policy"
        )
        
        let omegaRange = attributedString.mutableString.range(of: "Omega-R")
        attributedString.addAttribute(.link, value: Constants.omegaSite, range: omegaRange)
        
        let privacyRange = attributedString.mutableString.range(of: "Privacy Policy")
        attributedString.addAttribute(.link, value: Constants.privacySite, range: privacyRange)
        
        
        cell.update(with: attributedString)
        cell.textView.textColor = sectionType.textColor
        
        cell.backgroundColor = sectionType.backgroundColor
        
        return cell
    }
    
    // MARK: -
    
    func setupAttributedString(_ attributedString: NSMutableAttributedString, textColor: UIColor, firstLineHeadIndent: CGFloat = 15) -> NSMutableAttributedString {
        let fullRange = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 19, weight: .regular), range: fullRange)
        attributedString.addAttribute(.foregroundColor, value: textColor, range: fullRange)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = firstLineHeadIndent
        
        paragraphStyle.alignment = .justified
        
        if let languageString = UserDefaultsManager.shared.userLanguage, let language = NativeLanguage(rawValue: languageString) {
            paragraphStyle.alignment = language == .arabic ? .right : .justified
        }
        
        paragraphStyle.hyphenationFactor = 1.0
        
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        return attributedString
    }
}
