//
//  MainTableViewCell.swift
//  EnglishForBeginners
//
//  Created by Vladimir on 27.02.18.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit
import UICircularProgressRing

protocol MainTableViewCellDelegate: class {
    func buyButtonPressed(in cell: MainTableViewCell)
    func studyButtonPressed(in cell: MainTableViewCell)
    
    // TEMP
    
    func fakePurchasePressed(in cell: MainTableViewCell)
}

class MainTableViewCell: UITableViewCell {
    
    @IBOutlet weak var studyButton: UIButton!
    @IBOutlet weak var themeImage: UIImageView!
    @IBOutlet weak var mainBackground: UIView!
    @IBOutlet weak var shadowLayer: UIView!
    @IBOutlet weak var viewLocked: UIView!
    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var examPassedImageView: UIImageView!
    @IBOutlet weak var csStudyButtonWidth: NSLayoutConstraint!
    
    @IBOutlet weak var lowStarCountLabel: UILabel!
    @IBOutlet weak var lowStarImageView: UIImageView!
    @IBOutlet weak var lowStarView: UIView!
    
    @IBOutlet weak var eliteStarCountLabel: UILabel!
    @IBOutlet weak var eliteStarImageView: UIImageView!
    @IBOutlet weak var eliteStarView: UIView!
    
    @IBOutlet weak var topicsCountLabel: UILabel!
    
    weak var delegate: MainTableViewCellDelegate?
    
    var isOpened: Bool = true
    
    private let kStudyButtonFontSize: CGFloat = 19.0
    private let kStudyButtonSummaryInsets: CGFloat = 30.0
    private let kStudyButtonDefaultWidth: CGFloat = 116.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        prepareView()
    }
    
    func prepareView() {
        self.selectionStyle = .none
        
        viewLocked.isUserInteractionEnabled = isDebug
        
        mainBackground.layer.cornerRadius = 20
        mainBackground.layer.masksToBounds = true
        
        shadowLayer.layer.shadowOpacity = 0.5
        shadowLayer.layer.shadowOffset = CGSize(width: 0, height: 5)
        shadowLayer.layer.shadowRadius = 5
        shadowLayer.layer.shadowColor = UIColor.black.cgColor
        shadowLayer.layer.cornerRadius = 20
    }
    
    func cellState(opened: Bool) {
        viewLocked.isHidden = opened
        
        isOpened = opened
        
        csStudyButtonWidth.constant = kStudyButtonDefaultWidth
        
        studyButton.isUserInteractionEnabled = true
        studyButton.alpha = 1.0
        
        if opened {
            studyButton.isHidden = false
            studyButton.backgroundColor = AppColors.mainScreenStudyButton
            adjustStudyButtonSize(withTitle: "view".localizedWithCurrentLanguage())
        } else {
            studyButton.backgroundColor = AppColors.mainScreenBuyButton
            updatePrice(nil)
        }
    }
    
    func updateStarAndProgress(_ starsCount: Int, starType: StarType, examPassed: Bool) {
        
        if isOpened {
            viewLocked.isHidden = true
            topicsCountLabel.isHidden = true
            if starType.isElite {
                lowStarView.isHidden = true
                eliteStarView.isHidden = false
                eliteStarImageView.image = starType.icon
                eliteStarCountLabel.textColor = starType.textColor
                eliteStarCountLabel.text = "\(starsCount)/\(Constants.maximumStarsAmount)"
            } else {
                eliteStarView.isHidden = true
                lowStarView.isHidden = false
                lowStarImageView.image = starType.icon
                lowStarCountLabel.textColor = starType.textColor
                lowStarCountLabel.text = "\(starsCount)/\(Constants.maximumStarsAmount)"
            }
        } else {
            viewLocked.isHidden = false
            topicsCountLabel.isHidden = false
            eliteStarView.isHidden = true
            lowStarView.isHidden = true
        }
        
        examPassedImageView.isHidden = !examPassed
    }
    
    func updatePrice(_ priceWithCurrency: String?) {
        if let priceWithCurrency = priceWithCurrency {
            adjustStudyButtonSize(withTitle: "main-buy-button".localizedWithCurrentLanguage() + " \(priceWithCurrency)")
            studyButton.alpha = 1.0
            studyButton.isUserInteractionEnabled = true
        } else {
            studyButton.setTitle("main-buy-button".localizedWithCurrentLanguage(), for: .normal)
            studyButton.alpha = 0.8
            studyButton.isUserInteractionEnabled = false
        }        
    }
    
    func adjustStudyButtonSize(withTitle title: String) {
        let width = title.or_estimatedSize(font: UIFont.systemFont(ofSize: kStudyButtonFontSize, weight: .medium)).width + kStudyButtonSummaryInsets
        if width > kStudyButtonDefaultWidth {
            csStudyButtonWidth.constant = width
        }
        studyButton.setTitle(title, for: .normal)
    }
    
    // MARK: - Action
    
    @IBAction func buyButtonPressed(_ sender: Any) {
        if isOpened {
            delegate?.studyButtonPressed(in: self)
        } else {
            delegate?.buyButtonPressed(in: self)
        }
    }
    
    @IBAction func fakePurchasePressed(_ sender: Any) {
        if !isOpened {
            delegate?.fakePurchasePressed(in: self)
        }
    }
    
}
