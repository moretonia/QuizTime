//
//  LearningSection+CoreDataClass.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 01/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//
//

import Foundation
import CoreData

@objc(LearningSection)
public class LearningSection: NSManagedObject {
    var wordsIds: [String] {
        get {
            return vocabularyItemIds as? [String] ?? []
        }
        set {
            vocabularyItemIds = newValue as NSArray
        }
    }
}
