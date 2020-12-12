//
//  Profile+CoreDataClass.swift
//  EnglishForBeginners
//
//  Created by Sergey Aleksandrov on 05/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Profile)
public class Profile: NSManagedObject {
    func starsCount(for lessonType: LessonType) -> Int {
        guard let starsInfo = starsInfo, let count = starsInfo[lessonType.rawValue] else {
            return 0
        }
        
        return count
    }
}
