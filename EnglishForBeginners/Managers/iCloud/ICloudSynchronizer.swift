//
//  ICloudSynchronizer.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 13/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation

class ICloudSynchronizer {
    static func synchronizeWithICloud() {
        synchronizeStars()
        synchronizeThemes()
        synchronizeExperience()
    }
    
    static func synchronizeExperience() {
        guard let profile = Profile.mr_findFirst() else {
            ICloudProvider.experience { (experience) in
                ProfileManager.saveExperience(experience: experience, difference: 0)
            }
            return
        }
        
        let unsynchronisedExperience = Int(profile.unsynchronisedExperience)
        if unsynchronisedExperience <= 0 {
            return
        }
        
        ICloudSaver.addExperience(experience: unsynchronisedExperience) { (error) in
            if error == nil {
                ProfileManager.removeUnsynchronisedExperience()
            }
        }
    }
    
    static func synchronizeStars() {
        ICloudProvider.starsInfo { (starsInfo, error) in
            guard error == nil else {
                return
            }
            
            guard let topics = Topic.mr_findAll() as? [Topic] else {
                return
            }
            
            for topic in topics {
                guard let themeName = topic.theme?.name, let topicName = topic.name else {
                    return
                }
                
                let topicStarsInfo = starsInfo.filter({ (info) -> Bool in
                    return info.themeName == themeName && info.topicName == topicName
                })
                
                synchronizeTopicStars(topic: topic, starsInfo: topicStarsInfo)
            }
        }
    }
    
    static func synchronizeTopicStars(topic: Topic, starsInfo: [StarsInfo]) {
        let lessonTypes: [LessonType] = [LessonType.association, LessonType.pronunciation, LessonType.spelling, LessonType.translation]
        
        for lessonType in lessonTypes {
            let starInfo = starsInfo.filter { (info) -> Bool in
                info.lessonType == lessonType
            }.first
            
            let starCount = starInfo?.starsCount ?? 0
            
            if topic.starsCountFor(lessonType: lessonType) > starCount {
                ICloudSaver.starCountChanged(themeName: topic.theme!.name!, topicName: topic.name!, lessonType: lessonType, count: topic.starsCountFor(lessonType: lessonType)) { (error) in
                }
            }
        }
    }
    
    static func synchronizeThemes() {
        guard let themes = Theme.mr_findAll() as? [Theme], let profile = Profile.mr_findFirst() else {
            return
        }
        
        if let unsavedThemes = profile.purchasedThemes, !unsavedThemes.isEmpty {
            ICloudSaver.themesPurchased(themesNames: unsavedThemes) { (unsavedThemes) in
                ProfileManager.saveUnsynchronizedPurchases(themeNames: unsavedThemes)
            }
        }
        
        ICloudProvider.themes { (themesInfo, error) in
            guard error == nil, let themesInfo = themesInfo else {
                return
            }
            
            for theme in themes {
                guard let themeName = theme.name else {
                    continue
                }
                
                let themeInfo = themesInfo.filter({ (info) -> Bool in
                    return info.themeName == themeName
                }).first
                
                if theme.passed, themeInfo?.examPassed != theme.passed {
                    ICloudSaver.examPassed(themeName: themeName, completion: { (error) in
                    })
                }
            }
        }
    }
}


