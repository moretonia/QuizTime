//
//  ICloudModel.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 10/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation
import CloudKit

protocol CloudInfoProtocol {
    init?(record: CKRecord)
}

struct StarsInfo: CloudInfoProtocol {
    var themeName: String
    var topicName: String
    var starsCount: Int
    var lessonType: LessonType
    
    init?(record: CKRecord) {
        guard let topicName = record.value(forKey: ICloudConstants.fieldTopicName) as? String,
            let themeName = record.value(forKey: ICloudConstants.fieldThemeName) as? String,
            let starsCount = record.value(forKey: ICloudConstants.fieldStarCount) as? Int,
            let lessonTypeStr = record.value(forKey: ICloudConstants.fieldLessonType) as? String,
            let lessonType = LessonType(rawValue: lessonTypeStr) else {
                return nil
        }
        
        self.init(themeName: themeName, topicName: topicName, starsCount: starsCount, lessonType: lessonType)
    }
    
    init(themeName: String, topicName: String, starsCount: Int, lessonType: LessonType) {
        self.themeName = themeName
        self.topicName = topicName
        self.starsCount = starsCount
        self.lessonType = lessonType
        
    }
}

class ThemeInfo: CloudInfoProtocol {
    var themeName: String
    var isPurchased: Bool
    var examPassed: Bool
    
    var starsCount: Int
    
    convenience required init?(record: CKRecord) {
        guard let themeName = record.value(forKey: ICloudConstants.fieldThemeName) as? String,
            let isPurchasedInt = record.value(forKey: ICloudConstants.fieldIsOpen) as? Int,
            let examPassedInt = record.value(forKey: ICloudConstants.fieldExamPassed) as? Int else {
                return nil
        }
        
        let isPurchased = isPurchasedInt == 1
        let examPassed = examPassedInt == 1
        
        self.init(themeName: themeName, isPurchased: isPurchased, examPassed: examPassed, starsCount: 0)
    }
    
    init(themeName: String, isPurchased: Bool, examPassed: Bool, starsCount: Int) {
        self.themeName = themeName
        self.isPurchased = isPurchased
        self.examPassed = examPassed
        
        self.starsCount = starsCount
    }
}
