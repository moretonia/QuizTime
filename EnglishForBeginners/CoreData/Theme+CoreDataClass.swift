//
//  Theme+CoreDataClass.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 01/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Theme)
public class Theme: LearningSection {
    var convertedTopics: [Topic] {
        get {
            return topics?.array as? [Topic] ?? []
        }
        set {
            topics = NSOrderedSet(array: newValue)
        }
    }
    
    var starsCount: Int {
        
        let iCloudStars = Int(iCloudStarsCount)
        
        return starsFromTopics > iCloudStars ? starsFromTopics : iCloudStars
    }
    
    var starsFromTopics: Int {
        var count = 0
        
        for topic in convertedTopics {
            for starsInfo in topic.starsSet {
                count += Int(starsInfo.starCount)
            }
        }
        
        return count
    }
    
    var needToUpdateStarsFromICloud: Bool {
        return Int(iCloudStarsCount) > starsFromTopics
    }
    
    func updateTheme(with themeInfo: ThemeInfo) {
        if !passed {
            passed = themeInfo.examPassed
        } else {
            if !themeInfo.examPassed {
                ICloudSaver.examPassed(themeName: name!, completion: { (error) in
                })
            }
        }
        
        if !opened {
            opened = opened || themeInfo.isPurchased
        }
        
        iCloudStarsCount = Int64(themeInfo.starsCount)
    }
}
