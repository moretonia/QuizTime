//
//  Theme+CoreDataProperties.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 24/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//
//

import Foundation
import CoreData


extension Theme {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Theme> {
        return NSFetchRequest<Theme>(entityName: "Theme")
    }

    @NSManaged public var iCloudStarsCount: Int64
    @NSManaged public var id: Int16
    @NSManaged public var opened: Bool
    @NSManaged public var passed: Bool
    @NSManaged public var topics: NSOrderedSet?
    @NSManaged public var nativeWord: NativeWord?

}

// MARK: Generated accessors for topics
extension Theme {

    @objc(insertObject:inTopicsAtIndex:)
    @NSManaged public func insertIntoTopics(_ value: Topic, at idx: Int)

    @objc(removeObjectFromTopicsAtIndex:)
    @NSManaged public func removeFromTopics(at idx: Int)

    @objc(insertTopics:atIndexes:)
    @NSManaged public func insertIntoTopics(_ values: [Topic], at indexes: NSIndexSet)

    @objc(removeTopicsAtIndexes:)
    @NSManaged public func removeFromTopics(at indexes: NSIndexSet)

    @objc(replaceObjectInTopicsAtIndex:withObject:)
    @NSManaged public func replaceTopics(at idx: Int, with value: Topic)

    @objc(replaceTopicsAtIndexes:withTopics:)
    @NSManaged public func replaceTopics(at indexes: NSIndexSet, with values: [Topic])

    @objc(addTopicsObject:)
    @NSManaged public func addToTopics(_ value: Topic)

    @objc(removeTopicsObject:)
    @NSManaged public func removeFromTopics(_ value: Topic)

    @objc(addTopics:)
    @NSManaged public func addToTopics(_ values: NSOrderedSet)

    @objc(removeTopics:)
    @NSManaged public func removeFromTopics(_ values: NSOrderedSet)

}
