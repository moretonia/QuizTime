//
//  ProfileManager.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 11/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation
import ORCoreData

class ProfileManager {
    static func saveStarsCount(starsInfo: [StarsInfo], completion: @escaping (() -> ())) {
        ORCoreDataSaver.sharedInstance.saveData({ (localContext, cancelSaving) in
            guard let profile = ORCoreDataEntityFinderAndCreator(localContext).findFirstEntityOfType(Profile.self) ?? ORCoreDataEntityFinderAndCreator(localContext).createEntityOfType(Profile.self) else {
                return
            }
            
            let lessonsType: [LessonType] = [.association, .pronunciation, .spelling, .translation]
            
            profile.starsInfo = [:]
            
            for lessonType in lessonsType {
                
                var starForLessonType: Int = 0
                
                let starsInfoForLessonType = starsInfo.filter { (starsInfo) -> Bool in
                    return starsInfo.lessonType == lessonType
                }
                
                for starInfo in starsInfoForLessonType {
                    starForLessonType += starInfo.starsCount
                }
                
                profile.starsInfo?[lessonType.rawValue] = starForLessonType
            }
        }) {
            completion()
        }
    }
    
    static func removeStarsFromProfile(completion: @escaping (() -> ())) {
        ORCoreDataSaver.sharedInstance.saveData({ (localContext, cancelSaving) in
            guard let profile = ORCoreDataEntityFinderAndCreator(localContext).findFirstEntityOfType(Profile.self) ?? ORCoreDataEntityFinderAndCreator(localContext).createEntityOfType(Profile.self) else {
                return
            }
            
            profile.starsInfo = nil
        }) {
            completion()
        }
    }
    
    static func starsCount(for lessonType: LessonType) -> Int {
        guard let profile = Profile.mr_findFirst() else {
            return 0
        }
        
        return profile.starsCount(for: lessonType)
    }
    
    static func needToUpdateProfileFromICloud() -> Bool {
        guard let profile = Profile.mr_findFirst() else {
            return true
        }
        
        return profile.starsInfo == nil || profile.experience == 0
    }
    
    static func saveExperience(experience: Int, difference: Int, completion: (() -> ())? = nil) {
        
        ORCoreDataSaver.sharedInstance.saveData({ (localContext, cancelSaving) in
            guard let profile = ORCoreDataEntityFinderAndCreator(localContext).findFirstEntityOfType(Profile.self) ?? ORCoreDataEntityFinderAndCreator(localContext).createEntityOfType(Profile.self) else {
                return
            }
            
            ICloudSaver.experienceChanged(experience: experience, completion: { (error) in
                if error != nil {
                    ORCoreDataSaver.sharedInstance.saveData({ (localContext, cancelSaving) in
                        guard let profile = ORCoreDataEntityFinderAndCreator(localContext).findFirstEntityOfType(Profile.self) ?? ORCoreDataEntityFinderAndCreator(localContext).createEntityOfType(Profile.self) else {
                            return
                        }
                        
                        profile.unsynchronisedExperience = profile.unsynchronisedExperience + Int32(difference)
                    }) {
                    }
                }
            })
            
            if profile.experience < experience {
                KochavaEventTracker.trackExperienceChangeIfNeeded(previousExperience: Int(profile.experience), currentExperience: experience)
                profile.experience = Int32(experience)              
            }
        }) {
            completion?()
        }
    }
    
    static func getOverallExperience() -> Int {
        guard let profile = Profile.mr_findFirst() else {
            return 0
        }
        return Int(profile.experience)
    }
    
    static func saveUnsynchronizedPurchases(themeNames: [String]) {
        ORCoreDataSaver.sharedInstance.saveData({ (localContext, cancelSaving) in
            guard let profile = ORCoreDataEntityFinderAndCreator(localContext).findFirstEntityOfType(Profile.self) ?? ORCoreDataEntityFinderAndCreator(localContext).createEntityOfType(Profile.self) else {
                return
            }
            if profile.purchasedThemes == nil {
                profile.purchasedThemes =  themeNames
            } else {
                profile.purchasedThemes?.append(contentsOf: themeNames)
            }
        }) {
        }
    }
    
    static func removeUnsynchronisedExperience() {
        ORCoreDataSaver.sharedInstance.saveData({ (localContext, cancelSaving) in
            guard let profile = ORCoreDataEntityFinderAndCreator(localContext).findFirstEntityOfType(Profile.self) ?? ORCoreDataEntityFinderAndCreator(localContext).createEntityOfType(Profile.self) else {
                return
            }
            
            profile.unsynchronisedExperience = 0
        }) {
        }
    }
    
    static func getUserRank() -> Rank {
        let experience = getOverallExperience()
        
        let rankCalculator = RankCalculator(experience: experience)
        
        return rankCalculator.rank
    }
}
