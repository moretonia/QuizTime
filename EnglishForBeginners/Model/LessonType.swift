//
//  LessonType.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 15/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation
import UIKit

enum LessonType: String {
    case association
    case translation
    case pronunciation
    case spelling
    case listenType
    case lookType
    
    static var types: [LessonType] {
        return [.association, .translation, .pronunciation, .spelling, .listenType, .lookType]
    }
    
    private var lessonTypeString: String {
        switch self {
        case .association:
            return "matching"
        case .translation:
            return "translation"
        case .pronunciation:
            return "pronunciation"
        case .spelling:
            return "spelling"
        case .listenType:
            return "listen"
        case .lookType:
            return "look"
        }
    }
    
    var englishTitle: String {
        return lessonTypeString.localized(NativeLanguage.english.currentLocale)
    }
    
    // TODO: translate
    // Need to translate lesson type name to the other languages
    var title: String {
//        return lessonTypeString.localizedWithCurrentLanguage()
        return lessonTypeString.localized(NativeLanguage.english.currentLocale)
    }
    
    var image: UIImage? {
        return icon
    }
    
//    var message: String {
//        switch self {
//        case .association:
//            return "match".localizedWithCurrentLanguage()
//        case .translation:
//            return "translate".localizedWithCurrentLanguage()
//        case .pronunciation:
//            return "listen-and-say".localizedWithCurrentLanguage()
//        case .spelling:
//            return "spell".localizedWithCurrentLanguage()
//        // TODO: translate
//        case .lookType:
//            return "look-and-type".localizedWithCurrentLanguage()
//        // TODO: translate
//        case .listenType:
//            return "listen-and-type".localizedWithCurrentLanguage()
//        }
//    }
    
    var message: String {
        switch self {
        case .association:
            return "match".localized(NativeLanguage.english.currentLocale)
        case .translation:
            return "translate".localized(NativeLanguage.english.currentLocale)
        case .pronunciation:
            return "listen-and-say".localized(NativeLanguage.english.currentLocale)
        case .spelling:
            return "spell".localized(NativeLanguage.english.currentLocale)
        // TODO: translate
        case .lookType:
            return "look-and-type".localized(NativeLanguage.english.currentLocale)
        // TODO: translate
        case .listenType:
            return "listen-and-type".localized(NativeLanguage.english.currentLocale)
        }
    }
    
    var icon: UIImage {
        switch self {
        case .association:
            return #imageLiteral(resourceName: "icon-association")
        case .translation:
            return #imageLiteral(resourceName: "icon-translation")
        case .pronunciation:
            return #imageLiteral(resourceName: "icon-pronunciation")
        case .spelling:
            return #imageLiteral(resourceName: "icon-spelling")
        // TODO: need to update icons to mactch overall style
        case .lookType:
            return UIImage(named: "icon_look")!
        // TODO: need to update icons to mactch overall style
        case .listenType:
            return UIImage(named: "icon_listen")!
        }
    }
    
    var roundNumbers: Int {
        12
    }
    
    var answersPackSize: Int {
        switch self {
        case .association, .translation:
            return 4
        case .pronunciation, .spelling, .lookType, .listenType:
            return 1
        }
    }
    
    var multipleAnswers: Bool {
        return answersPackSize != 1
    }
    
    var successfulLearningCoef: Int {
        1
    }
    
    var multipleAttemptsAvailable: Bool {
        false
    }
    
    var isMainWordEnglish: Bool {
        switch self {
        case .association, .translation, .pronunciation, .listenType:
            return true
        case .spelling, .lookType:
            return false
        }
    }
    
    var needToShowTitleImage: Bool {
        switch self {
        case .lookType:
            return true
        default:
            return false
        }
    }
    
    var needToShowWord: Bool {
        switch self {
        case .listenType, .lookType:
            return false
        default:
            return true
        }
    }
    
    var saveAnswerWhenGoToNextQuestion: Bool {
        switch self {
        case .pronunciation:
            return true
        default:
            return false
        }
    }
    
    var attemptsBeforeSkipping: Int {
        switch self {
        case .pronunciation:
            return 2
        case .association, .translation:
            return 1
        default:
            return 0
        }
    }
    
    func message(for round: Int) -> String {
        return ""
    }
}
