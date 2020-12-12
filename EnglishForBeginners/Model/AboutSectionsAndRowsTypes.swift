//
//  AboutSectionsAndRowsTypes.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 19/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation
import UIKit

enum AboutSectionType: Int {
    case description
    case mechanics
    case rewards
    case copyrights
    
    var headerHeight: CGFloat {
        return 86
    }
    
    var isHeaderExist: Bool {
        switch self {
        case .mechanics, .rewards:
            return true
        default:
            return false
        }
    }
    
    var numberOfCells: Int {
        switch self {
        case .description, .copyrights:
            return 1
        case .mechanics:
            return 5
        case .rewards:
            return 6
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .mechanics:
            return AppColors.aboutMechanicsBackgroundColor
        default:
            return .white
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .mechanics:
            return .white
        default:
            return AppColors.aboutDefaultTextColor
        }
    }
}

enum AboutMechanicsType: Int {
    case description = 0
    case matching
    case translator
    case pronunciation
    case spelling
    case listenType
    case lookType
    
    var text: String {
        switch self {
        case .description:
            return "about-mechanics-description".localizedWithCurrentLanguage()
        case .matching:
            return "about-mechanics-matching-description".localizedWithCurrentLanguage()
        case .pronunciation:
            return "about-mechanics-pronunciation-description".localizedWithCurrentLanguage()
        case .spelling:
            return "about-mechanics-spelling-description".localizedWithCurrentLanguage()
        case .translator:
            return "about-mechanics-translator-description".localizedWithCurrentLanguage()
        // TODO: translate
        case .listenType:
            return "about-mechanics-listen-description".localizedWithCurrentLanguage()
        // TODO: translate
        case .lookType:
            return "about-mechanics-look-description".localizedWithCurrentLanguage()
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .matching:
            return LessonType.association.icon
        case .pronunciation:
            return LessonType.pronunciation.icon
        case .spelling:
            return LessonType.spelling.icon
        case .translator:
            return LessonType.translation.icon
        default:
            return nil
        }
    }
    
    var title: String? {
        switch self {
        case .matching:
            return LessonType.association.title
        case .pronunciation:
            return LessonType.pronunciation.title
        case .spelling:
            return LessonType.spelling.title
        case .translator:
            return LessonType.translation.title
        case .listenType:
            return LessonType.listenType.title
        case .lookType:
            return LessonType.lookType.title
        default:
            return nil
        }
    }
}

enum AboutRewardsType: Int {
    case smallStar = 0
    case bronzeStar
    case silverStar
    case goldenStar
    case examPassed
    case description
    
    var text: String {
        switch self {
        case .description:
            return "about-rewards-description".localizedWithCurrentLanguage()
        case .smallStar:
            return "about-rewards-little-star-description".localizedWithCurrentLanguage()
        case .bronzeStar:
            return "about-rewards-bronze-star-description".localizedWithCurrentLanguage()
        case .silverStar:
            return "about-rewards-silver-star-description".localizedWithCurrentLanguage()
        case .goldenStar:
            return "about-rewards-golden-star-description".localizedWithCurrentLanguage()
        case .examPassed:
            return "about-rewards-passed-exam-description".localizedWithCurrentLanguage()
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .smallStar:
            return #imageLiteral(resourceName: "icon-star-small-filled")
        case .bronzeStar:
            return #imageLiteral(resourceName: "icon-star-bronze")
        case .silverStar:
            return #imageLiteral(resourceName: "icon-star-silver")
        case .goldenStar:
            return #imageLiteral(resourceName: "icon-star-gold")
        case .examPassed:
            return #imageLiteral(resourceName: "exam-completed")
        default:
            return nil
        }
    }
}
