//
//  UserDefaultsManager.swift
//  EnglishForBeginners
//
//  Created by Sergey Aleksandrov on 05/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation
import ORCommonCode_Swift

class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    
    private init() {}
    
    enum UserDefaultsKey: String {
        case userLanguage
        case currentThemesPackCreationDate
        case currentThemesPackThemesNames
        case dateWhenLastPackWasRemoved
        
        case TimeWhenSessionStarted
        
        case lastMotivationalVideoNumber
    }
    
    var userLanguage: String? {
        get {
            return UserDefaults.standard.string(forKey: UserDefaultsKey.userLanguage.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.userLanguage.rawValue)
            UserDefaults.standard.synchronize()
            or_postNotification(Notifications.languageDidChange)
            
            if let languageString = newValue, let language = NativeLanguage(rawValue: languageString) {
                AnalyticsHelper.logEventWithParameters(event: .Profile_Language_Сhoiced, themeId: nil, topicId: nil, typeOfLesson: nil, starsCount: nil, language: language)
            }
        }
    }
    
    var currentSessionStartTime: Date? {
        get {
            return UserDefaults.standard.object(forKey: UserDefaultsKey.TimeWhenSessionStarted.rawValue) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.TimeWhenSessionStarted.rawValue)
        }
    }
    
    var currentThemesPackCreationTime: Date? {
        get {
            return UserDefaults.standard.object(forKey: UserDefaultsKey.currentThemesPackCreationDate.rawValue) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.currentThemesPackCreationDate.rawValue)
        }
    }
    
    var currentThemesPackRemovingTime: Date? {
        get {
            return UserDefaults.standard.object(forKey: UserDefaultsKey.dateWhenLastPackWasRemoved.rawValue) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.dateWhenLastPackWasRemoved.rawValue)
        }
    }
    
    var currentThemesPackThemesNames: [String]? {
        get {
            return UserDefaults.standard.object(forKey: UserDefaultsKey.currentThemesPackThemesNames.rawValue) as? [String]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.currentThemesPackThemesNames.rawValue)
        }
    }
    
    var lastMotivationalVideoNumber: Int? {
        get {
            return UserDefaults.standard.object(forKey: UserDefaultsKey.lastMotivationalVideoNumber.rawValue) as? Int
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.lastMotivationalVideoNumber.rawValue)
        }
    }
}
