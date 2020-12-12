//
//  LearningProgressManager.swift
//  EnglishForBeginners
//
//  Created by Sergey Aleksandrov on 23/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit
import ORCoreData

class LearningProgressManager: BaseManager {
    
    static func addStars(count: Int, lessonType: LessonType, topicName: String, completion: (() -> ())? = nil) {
        ORCoreDataSaver.sharedInstance.saveData({ (localContext, cancelSaving) in
            let coreDataEntityFinderAndCreator = ORCoreDataEntityFinderAndCreator(localContext)
            
            if let profile = Profile.mr_findFirst(in: localContext), let currentStarCount = profile.starsInfo?[lessonType.rawValue] {
                profile.starsInfo?[lessonType.rawValue] = currentStarCount + count
            }
            
            // themeName is not necessary
            let starInfo = StarsInfo(themeName: "", topicName: topicName, starsCount: count, lessonType: lessonType)
            
            let _ = addStars(from: starInfo, coreDataEntityFinderAndCreator: coreDataEntityFinderAndCreator)
        }) {
            completion?()
        }
    }
    
    static func addStars(from starsInfo: [StarsInfo], completion: (() -> ())? = nil) {
        ORCoreDataSaver.sharedInstance.saveData({ (localContext, cancelSaving) in
            let coreDataEntityFinderAndCreator = ORCoreDataEntityFinderAndCreator(localContext)
            for info in starsInfo {
                _ = addStars(from: info, coreDataEntityFinderAndCreator: coreDataEntityFinderAndCreator)
            }
        }) {
            completion?()
        }
            
    }
    
    fileprivate static func addStars(from starInfo: StarsInfo, coreDataEntityFinderAndCreator: ORCoreDataEntityFinderAndCreator) -> Topic?  {
        
        guard let topic = coreDataEntityFinderAndCreator.findEntityOfType(Topic.self, byAttribute: Keys.name, withValue: starInfo.topicName) else {
            return nil
        }
        
        let starCount = starInfo.starsCount
        
        var oldStarsCount = 0
        
        if let oldStarsForLesson = topic.starsFor(lessonType: starInfo.lessonType) {
            oldStarsCount = Int(oldStarsForLesson.starCount)
            if oldStarsCount < starCount {
                topic.removeFromStars(oldStarsForLesson)
            } else {
                return nil
            }
        }
        
        guard let newStarsForLesson = coreDataEntityFinderAndCreator.createEntityOfType(Stars.self) else {
            return nil
        }
        
        newStarsForLesson.starCount = Int16(starCount)
        newStarsForLesson.lessonType = starInfo.lessonType.rawValue
        topic.addToStars(newStarsForLesson)

        return topic
    }
    
    static func calculateStarsAndExperience(_ result: Float, lessonType: LessonType, topic: Topic, completion: @escaping (_ stars: Int, _ experience: Int) -> ()) {
        
        var stars = 0
        var experience = 0
        
        switch result {
        case 0.7..<0.8:
            stars = 1
        case 0.8..<0.9:
            stars = 2
        case 0.9...1:
            stars = 3
        default:
            break
        }
        
        var oldStars = 0
        
        if let oldStarsForLesson = topic.starsFor(lessonType: lessonType)?.starCount {
            oldStars = Int(oldStarsForLesson)
            if oldStarsForLesson < stars {
                experience = (stars - oldStars) * Constants.experienceForStar + (stars == 3 ? Constants.experienceForMaximumResult : 0)
            }
        } else {
            experience = stars * Constants.experienceForStar + (stars == 3 ? Constants.experienceForMaximumResult : 0)
        }
    
        guard let theme = topic.theme else {
            completion(stars, experience)
            return
        }
        
        let medalBefore = ThemeManager.starType(of: theme)
        
        LearningProgressManager.addStars(count: stars, lessonType: lessonType, topicName: topic.name!) {
            let medalAfter = ThemeManager.starType(of: theme)
            
            if medalBefore < medalAfter {
                experience += (medalAfter.rawValue - medalBefore.rawValue) * Constants.experienceForMedal
            }
            
            if stars > oldStars {
                if let themeName = topic.theme?.name, let topicName = topic.name {
                    ICloudSaver.starCountChanged(themeName: themeName, topicName: topicName, lessonType: lessonType, count: stars - oldStars, completion: { (error) in
                        DispatchQueue.main.async {
                            completion(stars, experience)
                        }
                    })
                }
            } else {
                completion(stars, experience)
            }
        }
    }
    
    static func calculateExperience(theme: Theme) -> Int {
        if theme.passed {
            return ExamConfig.experienceForOthersExams
        } else {
            return ExamConfig.experienceForFirstExam + Constants.experienceForPlatinumMedal
        }
    }
    
    static func numberOfStarsFor(lessonType: LessonType) -> Int {
        guard let themes = Theme.mr_findAll() as? [Theme] else {
            return 0
        }
    
        var starsCount = 0
        
        for theme in themes {
            for topic in theme.convertedTopics {
                if let stars = topic.starsFor(lessonType: lessonType) {
                    starsCount += Int(stars.starCount)
                }
            }
        }
        
        return starsCount
    }
    
    static func maximumNumberOfStarsForLessonType() -> Int {
        guard let themes = Theme.mr_findAll() as? [Theme] else {
            return 0
        }
        
        return themes.count * 6 * 3
    }
    
    static func examPassed(themeName: String, completion: (() -> ())? = nil) {
        ORCoreDataSaver.sharedInstance.saveData({ (localContext, cancelSaving) in
            guard let theme = ORCoreDataEntityFinderAndCreator(localContext).findEntityOfType(Theme.self, byAttribute: Keys.name, withValue: themeName) else {
                cancelSaving = true
                return
            }
            
            ICloudSaver.examPassed(themeName: themeName, completion: { (error) in
            })
            
            theme.passed = true
        }) {
            completion?()
        }
    }
}
