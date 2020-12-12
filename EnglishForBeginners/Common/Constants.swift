//
//  Constants.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 27/02/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation

struct Keys {
    static let name = "name"
    static let id = "id"
}

struct ContentPath {
    static let themeListJsonName = "theme-list"
    static let vocabularyItemsPathPrefix = "english-words-"
    static let themesPathPrefix = "theme-"
    static let translationsPathPrefix = "translation-"
}

struct Constants {
    static let maximumStarsAmount: Int = 108
    
    static let experienceForStar: Int = 150
    static let experienceForMaximumResult = 50
    static let experienceForMedal: Int = 750
    static let experienceForPlatinumMedal: Int = 2000
    
    static let purchaseThemePrefix: String = "theme_"
    
    static let purchaseStatus: String = "purchaseStatus"
    static let purchasesInfo: String = "purchasesInfo"
    
    
    static let timeBetweenPacks: Double = 4 * 60 * 60
    static let minPackLifeTime: Double = 4 * 60 * 60
    static let maxPackLifeTime: Double = 6 * 60 * 60
    
    static let omegaSite: String = "https://omega-r.com/?app=model_english"
    
    static let privacySite: String = "https://www.iubenda.com/privacy-policy/32551649"
}

struct ICloudConstants {
    static let starsRecordType: String = "Stars"
    static let themeRecordType: String = "Theme"
    static let usersRecordType: String = "Profile"
    
    static let fieldLessonType: String = "lessonType"
    static let fieldStarCount: String = "starCount"
    static let fieldThemeName: String = "themeName"
    static let fieldTopicName: String = "topicName"
    static let fieldExamPassed: String = "examPassed"
    static let fieldIsOpen: String = "isOpen"
    static let fieldName: String = "name"
    static let fieldExperience: String = "experience"
}

struct Notifications {
    static let iApProductsFetched = "AppNotificationIApProductsFetched"
    static let iApProductPurchased = "AppNotificationIApProductPurchased"
    static let languageDidChange = "AppNotificationLanguageDidChange"
}

