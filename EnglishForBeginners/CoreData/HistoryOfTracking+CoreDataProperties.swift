//
//  HistoryOfTracking+CoreDataProperties.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 16/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//
//

import Foundation
import CoreData


extension HistoryOfTracking {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HistoryOfTracking> {
        return NSFetchRequest<HistoryOfTracking>(entityName: "HistoryOfTracking")
    }

    @NSManaged public var eventDate: Date?
    @NSManaged public var eventName: String?
    @NSManaged public var uid: String?

}
