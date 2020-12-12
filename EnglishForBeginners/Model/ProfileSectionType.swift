//
//  ProfileSectionType.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 03/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation
import UIKit

protocol ImageWithTitle {
    var image: UIImage? { get }
    var title: String { get }
}

enum ProfileSectionType: Int {
    case experience = 0
    case skill
    case global
    case local
    
    var headerHeight: CGFloat {
        return 86
    }
    
    var footerHeight: CGFloat {
        switch self {
        case .experience, .skill:
            return 50
        case .global:
            return 30
        default:
            return 0
        }
    }
    
    var isHeaderExist: Bool {
        switch self {
        case .local, .experience:
            return false
        default:
            return true
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .skill:
            return AppColors.profileSkillBackgroundColor
        default:
            return .white
        }
    }
    
    var headerContentColor: UIColor {
        switch self {
        case .skill:
            return AppColors.profileHighlightedHeaderContentColor
        default:
            return AppColors.profileDefaultHeaderContentColor
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .experience:
            return 150
        case .skill:
            return 53
        case .global, .local:
            return 55
        }
    }
    
    var image: UIImage? {
        switch self {
        case .experience:
            return #imageLiteral(resourceName: "icon-trophy")
        case .skill:
            return #imageLiteral(resourceName: "icon-star-outline")
        case .global:
            return #imageLiteral(resourceName: "icon-dots")
        default:
            return nil
        }
    }
    
    var title: String {
        switch self {
        case .experience:
            return "experience".localizedWithCurrentLanguage()
        case .skill:
            return "skills".localizedWithCurrentLanguage()
        default:
            return ""
        }
    }
    
    var cellNumber: Int {
        switch self {
        case .experience:
            return 1
        case .skill:
            return 6
        case .global:
            return 4
        case .local:
            return isDebug ? 3 : 2
        }
    }
    
    var otherCellTypes: [OtherCellType] {
        switch self {
        case .global:
            return OtherCellType.globalTypes
        case .local:
            return OtherCellType.localTypes
        default:
            return []
        }
    }
}

enum OtherCellType {
    case leaderboard
    case restore
    case rate
    case share
    
    case language
    case about
    case removeICloudInfo
    
    static var globalTypes: [OtherCellType] {
        return [.leaderboard, .restore, .rate, .share]
    }
    
    static var localTypes: [OtherCellType] {
        if isDebug {
            return [.language, .about, .removeICloudInfo]
        }
        return [.language, .about]
    }
    
    var image: UIImage? {
        switch self {
        case .leaderboard:
            return #imageLiteral(resourceName: "icon-leaderboard")
        case .restore:
            return #imageLiteral(resourceName: "icon-restore")
        case .rate:
            return #imageLiteral(resourceName: "icon-rate")
        case .share:
            return #imageLiteral(resourceName: "icon-share")
        case .about:
            return #imageLiteral(resourceName: "icon-about")
        default:
            return nil
        }
    }
    
    var title: String {
        switch self {
        case .leaderboard:
            return "leaderboard".localizedWithCurrentLanguage()
        case .restore:
            return "restore-purchases".localizedWithCurrentLanguage()
        case .rate:
            return "rate-us".localizedWithCurrentLanguage()
        case .share:
            return "share".localizedWithCurrentLanguage()
        case .language:
            return "change-language".localizedWithCurrentLanguage()
        case .about:
            return "about-us".localizedWithCurrentLanguage()
        case .removeICloudInfo:
            return "Remove purchases info from icloud"
        }
    }
}
