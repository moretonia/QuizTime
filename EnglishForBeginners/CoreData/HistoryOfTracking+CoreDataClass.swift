//
//  HistoryOfTracking+CoreDataClass.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 16/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//
//

import Foundation
import CoreData

@objc(HistoryOfTracking)
public class HistoryOfTracking: NSManagedObject {
    static func getTimeFromEventStartToDate(_ startEvent: AnalyticsEvent, uid: String, date: Date) -> TimeInterval? {
        let eventsList = mr_find(byAttribute: "uid", withValue: uid) as! [HistoryOfTracking]
        for event in eventsList {
            if event.eventName == startEvent.rawValue {
                return abs((event.eventDate?.timeIntervalSince(date))!)
            }
        }
        return nil
    }
}
