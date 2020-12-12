//
//  ThemeExamCVCell.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 14/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit
import ORCommonUI_Swift

protocol ThemeExamCVCellDelegate: class {
    func examButtonPressed()
}

class ThemeExamCVCell: UICollectionViewCell {
    
    enum ExamState {
        case locked
        case opened
        case passAgain
        case notPurchased
        
        var examDescription: String {
            switch self {
            case .locked:
                return String(format: "collect-stars-to-unlock".localizedWithCurrentLanguage(), ExamConfig.minimunStarsAmountForOpening)
            case .opened:
                return "can-start-quiz".localizedWithCurrentLanguage()
            case .passAgain:
                return "pass-quiz-again".localizedWithCurrentLanguage()
            default:
                return "Theme does not purchased"
            }
        }
    }
    
    @IBOutlet weak var labelExamName: UILabel!
    @IBOutlet weak var labelExamDescription: UILabel!
    @IBOutlet weak var labelStarsCount: UILabel!
    @IBOutlet weak var labelExperience: UILabel!
    
    @IBOutlet weak var buttonStartExam: ORRoundRectButton!
    
    @IBOutlet weak var viewPassExamAgainInfo: UIView!
    @IBOutlet weak var viewPassExamFirstTimeInfo: UIView!
    @IBOutlet weak var viewLocked: UIView!
    
    weak var delegate: ThemeExamCVCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        labelExperience.text = "+\(ExamConfig.experienceForOthersExams) xp"
    }
    
    func changeState(_ state: ExamState) {
        
        labelExamDescription.text = state.examDescription
        
        let isThemePurchased = state != .notPurchased
        
        viewPassExamAgainInfo.isHidden = !isThemePurchased || state != .passAgain
        viewPassExamFirstTimeInfo.isHidden = !isThemePurchased || state == .passAgain
        viewLocked.isHidden = isThemePurchased
        buttonStartExam.isHidden = !isThemePurchased
        labelStarsCount.isHidden = !isThemePurchased
        labelExamDescription.isHidden = !isThemePurchased
        
        buttonStartExam.backgroundColor = .white
        buttonStartExam.setTitleColor(AppColors.examScreenOpenedButtonTitle, for: .normal)
        buttonStartExam.setImage(nil, for: .normal)
        buttonStartExam.alpha = 1.0
        
        buttonStartExam.isEnabled = true
        
        let buttonTitle = state == .passAgain ? "repeat".localizedWithCurrentLanguage() : "quiz".localizedWithCurrentLanguage()
        buttonStartExam.setTitle(buttonTitle, for: .normal)
        
        if state == .locked {
            buttonStartExam.isEnabled = false
            buttonStartExam.alpha = 0.5
            buttonStartExam.setImage(#imageLiteral(resourceName: "icon-lock"), for: .normal)
            buttonStartExam.tintColor = AppColors.examScreenOpenedButtonTitle
        }
    }
    
    func updateProgress(_ starsCount: Int) {
        labelStarsCount.text = "\(starsCount)/\(Constants.maximumStarsAmount) "
    }
    
    // MARK: - Actions
    
    @IBAction func examButtonPressed(_ sender: Any) {
        delegate?.examButtonPressed()
    }
}
