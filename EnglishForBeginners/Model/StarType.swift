//
//  StarType.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 26/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation
import UIKit

enum StarType: Int {
    case empty = 0
    case bronze
    case silver
    case gold
    
    var icon: UIImage {
        switch self {
        case .empty:
            return #imageLiteral(resourceName: "icon-star-empty")
        case .bronze:
            return #imageLiteral(resourceName: "icon-star-bronze")
        case .silver:
            return #imageLiteral(resourceName: "icon-star-silver")
        case .gold:
            return #imageLiteral(resourceName: "icon-star-gold")
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .empty:
            return AppColors.emptyStarCount
        case .bronze:
            return AppColors.bronzeStarCount
        case .silver:
            return AppColors.silverStarCount
        case .gold:
            return AppColors.goldStarCount
        }
    }
    
    var isElite: Bool {
        return self == .silver || self == .gold
    }
    
    static func <(lhs: StarType, rhs: StarType) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    static func >(lhs: StarType, rhs: StarType) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }
}
