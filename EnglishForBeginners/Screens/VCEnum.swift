//
//  VCEnum.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 27/02/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation
import UIKit

enum VCEnum {
    case root
    
    case main
    
    case dictionary
    case levels
    case translation
    case spelling
    case pronunciation
    case findTheImage
    case typeTheWord
    case levelCompletion
    case levelFailed
    case topics
    
    case profile
    case language
    case about
    
    fileprivate var storyboardName: String {
        switch self {
        case .root:
            return "Root"
        case .main, .topics:
            return "Main"
        case .dictionary, .levels, .translation, .spelling, .pronunciation, .findTheImage, .typeTheWord, .levelCompletion, .levelFailed:
            return "LearningProcess"
        case .profile, .language, .about:
            return "Profile"
        }
    }
    
    fileprivate var vcName: String {
        return "\(self)"
    }
    
    var vc: UIViewController {
        return storyboard.instantiateViewController(withIdentifier: vcName)
    }
    
    var storyboard: UIStoryboard {
        return UIStoryboard(name: storyboardName, bundle: nil)
    }
}
