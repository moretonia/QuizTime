//
//  Stars+CoreDataProperties.swift
//  EnglishForBeginners
//
//  Created by Sergey Aleksandrov on 23/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//
//

import Foundation
import CoreData


extension Stars {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Stars> {
        return NSFetchRequest<Stars>(entityName: "Stars")
    }

    @NSManaged public var lessonType: String?
    @NSManaged public var starCount: Int16
    @NSManaged public var topic: Topic?

}
