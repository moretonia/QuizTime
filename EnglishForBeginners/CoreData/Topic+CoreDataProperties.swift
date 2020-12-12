//
//  Topic+CoreDataProperties.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 24/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//
//

import Foundation
import CoreData


extension Topic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Topic> {
        return NSFetchRequest<Topic>(entityName: "Topic")
    }

    @NSManaged public var stars: NSSet?
    @NSManaged public var theme: Theme?
    @NSManaged public var nativeWord: NativeWord?

}

// MARK: Generated accessors for stars
extension Topic {

    @objc(addStarsObject:)
    @NSManaged public func addToStars(_ value: Stars)

    @objc(removeStarsObject:)
    @NSManaged public func removeFromStars(_ value: Stars)

    @objc(addStars:)
    @NSManaged public func addToStars(_ values: NSSet)

    @objc(removeStars:)
    @NSManaged public func removeFromStars(_ values: NSSet)

}
