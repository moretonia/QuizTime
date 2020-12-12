//
//  AppData.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 13/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation
import UIKit

struct AppColors {
    // MARK: - Screens
    // MARK: Main screen
    static let mainScreenStudyButton = UIColor(62, 181, 241)
    static let mainScreenBuyButton = UIColor(34, 192, 100)
    static let emptyStarCount = UIColor.white
    static let bronzeStarCount = UIColor(255, 168, 120)
    static let silverStarCount = UIColor(206, 227, 246)
    static let goldStarCount = UIColor(255, 234, 0)
    
    // MARK: Topics screen
    static let examScreenOpenedButtonTitle = UIColor(50, 50, 50)
    static let examScreenLockedButton = UIColor(11, 38, 51).withAlphaComponent(0.25)
    
    // MARK: Dictionary
    static let currentPageControlItem = UIColor.white
    static let pageControlItems = UIColor.white.withAlphaComponent(0.3)
    
    // MARK: Learning Screens
    
    static let actionButtonVerificationColor = UIColor(62, 181, 241)
    static let actionButtonNextColor = UIColor(36, 204, 186)
    
    static let filledProgressViewColor = UIColor(62, 181, 241)
    static let emptyProgressViewColor = UIColor(229, 232, 233)
    
    static let notSelectedText = UIColor(50, 50, 50)
    static let selectedText = UIColor.white
    
    static let selectedCellColor = UIColor(255, 187, 56)
    static let notSelectedCellColor = UIColor(230, 230, 230)
    
    static let disabledMicroImage = UIColor(72, 92, 102)
    static let enabledMicroImage = UIColor.white
    
    static let spellingBorderColor = UIColor(204, 204, 204)
    
    static let actionViewCorrectColor = UIColor(151, 201, 64)
    static let actionViewWrongColor = UIColor(255, 119, 119)
    
    static let mistakeHeartColor = UIColor(229, 232, 233)
    
    // MARK: Pronounciation
    static let waveAnimationColor = UIColor(69, 89, 99).withAlphaComponent(0.2)
    
    
    // MARK: Spelling
    
    static let disabledTextFieldTextColor = UIColor(150, 150, 150)
    
    // MARK: Completion
    
    static let completionRankColor = UIColor(255, 234, 0)
    static let completionEmptyProgressColor = UIColor(117, 158, 46)
    static let completionExperienceToNextRankColor = UIColor(104, 140, 42)
    static let completionOtherColor = UIColor(104, 140, 42)
    
    // MARK: Profile
    
    static let profileProgressEmptyColor = UIColor(230, 230, 230)
    static let profileExperienceFilledProgressColor = UIColor(255, 187, 56)
    static let profileCurrentExperienceColor = UIColor(255, 187, 56)
    static let profileSkillFilledProgressColor = UIColor(62, 181, 241)
    static let profileSkillBackgroundColor = UIColor(245, 245, 245)
    static let profileRankColor = UIColor(50, 50, 50)
    static let profileExperienceToNextColor = UIColor(90, 90, 90)
    static let profileOtherColor = UIColor(230, 230, 230)
    static let profileHighlightedHeaderContentColor = UIColor(205, 205, 205)
    static let profileDefaultHeaderContentColor = UIColor(230, 230, 230)
    
    // MARK: Language
    
    static let flagBorderColor = UIColor(229, 232, 233)
    
    // MARK: About
    
    static let aboutBlueColor = UIColor(62, 181, 241)
    static let aboutDefaultTextColor = UIColor(90, 90, 90)
    static let aboutMechanicsBackgroundColor = UIColor(62, 181, 241)
}
