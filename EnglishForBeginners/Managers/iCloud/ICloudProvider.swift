//
//  ICloudProvider.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 10/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation
import CloudKit

class ICloudProvider {
    
    static func checkICloudAvailability(completion: @escaping (Bool) -> ()) {
        CKContainer.default().accountStatus { (status, error) in
            completion(status == .available)
        }
    }
    
    static let database = CKContainer.default().privateCloudDatabase
    
    static func starsInfo(themeName: String, completion: @escaping ([StarsInfo], Error?) -> ()) {
        let predicate = NSPredicate(format: "\(ICloudConstants.fieldThemeName) = %@", themeName)
        
        let query = CKQuery(recordType: ICloudConstants.starsRecordType, predicate: predicate)
        
        performStars(query: query, completion: completion)
    }
    
    static func starsInfo(completion: @escaping ([StarsInfo], Error?) -> ()) {
        let query = CKQuery(recordType: ICloudConstants.starsRecordType, predicate: NSPredicate(value: true))
        
        performStars(query: query, completion: completion)
    }
    
    static func performStars(query: CKQuery, completion: @escaping ([StarsInfo], Error?) -> ()) {
        database.perform(query, inZoneWith: nil) { (records, error) in
            guard error == nil, let records = records else {
                completion([], error)
                return
            }
            
            let starsInfo: [StarsInfo] = makeListOfInfo(with: records)
            
            completion(starsInfo, nil)
        }
    }
    
    
    static func closedThemes(completion: @escaping ([ThemeInfo], Error?) -> ()) {
        let predicate = NSPredicate(format: "\(ICloudConstants.fieldIsOpen) = %@", NSNumber.init(value: false))
        
        let query = CKQuery(recordType: ICloudConstants.themeRecordType, predicate: predicate)
        
        database.perform(query, inZoneWith: nil) { (records, error) in
            guard error == nil, let records = records else {
                completion([], error)
                return
            }
            
            let themesInfo: [ThemeInfo] = makeListOfInfo(with: records)
            
            completion(themesInfo, nil)
        }
    }
    
    static func experience(completion: @escaping (Int) -> ()) {
        let query = CKQuery(recordType: ICloudConstants.usersRecordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: ICloudConstants.fieldExperience, ascending: false)]
        
        database.perform(query, inZoneWith: nil) { (records, error) in
            guard error == nil, let records = records, let experience = records.first?.value(forKey: ICloudConstants.fieldExperience) as? Int else {
                completion(-1)
                return
            }
            
            completion(experience)
            
            if records.count > 1 {
                for i in 1..<records.count {
                    database.delete(withRecordID: records[i].recordID, completionHandler: { (_, _) in
                    })
                }
            }
        }
    }
    
    static func star(themeName: String, topicName: String, lessonType: LessonType, completion: @escaping (CKRecord?, Error?) -> ()) {
        let predicate = NSPredicate(format: "\(ICloudConstants.fieldThemeName) = %@ AND \(ICloudConstants.fieldTopicName) = %@ AND \(ICloudConstants.fieldLessonType) = %@", themeName, topicName, lessonType.rawValue)
        
        let query = CKQuery(recordType: ICloudConstants.starsRecordType, predicate: predicate)
        
        record(with: query, completion: completion)
    }
    
    static func user(completion: @escaping (CKRecord?, Error?) -> ()) {
        let query = CKQuery(recordType: ICloudConstants.usersRecordType, predicate: NSPredicate(value: true))
        
        record(with: query, completion: completion)
    }
    
    static func theme(themeName: String, completion: @escaping (CKRecord?, Error?) -> ()) {
        let predicate = NSPredicate(format: "\(ICloudConstants.fieldThemeName) = %@ ", themeName)
        
        let query = CKQuery(recordType: ICloudConstants.themeRecordType, predicate: predicate)
        
        record(with: query, completion: completion)
    }
    
    static func themesRecords(completion: @escaping ([CKRecord]?, Error?) -> ()) {
        let query = CKQuery(recordType: ICloudConstants.themeRecordType, predicate: NSPredicate(value: true))
        
        database.perform(query, inZoneWith: nil) { (records, error) in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            completion(records, nil)
        }
    }
    
    static func themes(completion: @escaping ([ThemeInfo]?, Error?) -> ()) {
        themesRecords { (records, error) in
            guard let records = records else {
                completion(nil, error)
                return
            }
            
            let themesInfo: [ThemeInfo] = makeListOfInfo(with: records)
            completion(themesInfo, nil)
        }
    }
    
    static func record(with query: CKQuery, completion: @escaping (CKRecord?, Error?) -> ()) {
        database.perform(query, inZoneWith: nil) { (records, error) in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            let record = records?.first
            
            completion(record, nil)
        }
    }
    
    
    static func makeListOfInfo<T: CloudInfoProtocol>(with records: [CKRecord]) -> [T] {
        var infoList = [T]()
        
        for record in records {
            if let info = T(record: record) {
                infoList.append(info)
            }
        }
        
        return infoList
    }
}
