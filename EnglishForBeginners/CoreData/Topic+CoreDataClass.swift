//
//  Topic+CoreDataClass.swift
//  
//
//  Created by Sergey Aleksandrov on 23/03/2018.
//
//

import Foundation
import CoreData

@objc(Topic)
public class Topic: LearningSection {

    var starsSet: Set<Stars> {
        get {
            return stars as? Set<Stars> ?? Set<Stars>()
        }
        set {
            stars = NSSet(set: newValue)
        }
    }
    
    func starsFor(lessonType: LessonType) -> Stars? {
        return starsSet.filter { $0.lessonType == lessonType.rawValue }.first
    }
    
    func starsCountFor(lessonType: LessonType) -> Int {
        return Int(starsFor(lessonType: lessonType)?.starCount ?? 0)
    }
}
