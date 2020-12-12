//
//  LearningSection+CoreDataProperties.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 24/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//
//

import Foundation
import CoreData


extension LearningSection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LearningSection> {
        return NSFetchRequest<LearningSection>(entityName: "LearningSection")
    }

    @NSManaged public var imageName: String?
    @NSManaged public var name: String?
    @NSManaged public var vocabularyItemIds: NSArray?

}
