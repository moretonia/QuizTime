//
//  ICloudSaver.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 10/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation
import CloudKit

class ICloudSaver {
    
    static let database = CKContainer.default().privateCloudDatabase
    
    // MARK: - ICloudSaver
    static func starCountChanged(themeName: String, topicName: String, lessonType: LessonType, count: Int, completion: @escaping (Error?) -> ()) {
        ICloudProvider.star(themeName: themeName, topicName: topicName, lessonType: lessonType) { (record, error) in
            if error != nil {
                completion(error)
                return
            }
            
            var record = record
            
            if record == nil {
                record = CKRecord(recordType: ICloudConstants.starsRecordType)
                record?.setObject(NSString(string: lessonType.rawValue), forKey: ICloudConstants.fieldLessonType)
                record?.setObject(NSString(string: themeName), forKey: ICloudConstants.fieldThemeName)
                record?.setObject(NSString(string: topicName), forKey: ICloudConstants.fieldTopicName)
            }
            
            setupRecord(record, recordType: ICloudConstants.starsRecordType, key: ICloudConstants.fieldStarCount, value: count, completion: completion)
        }
    }
    
    static func createThemeIfNeeded(themeName: String, completion: @escaping (Bool) -> ()) {
        ICloudProvider.theme(themeName: themeName) { (record, error) in
            guard record == nil, error == nil else {
                completion(false)
                return
            }
            
            var record = record
            
            record = CKRecord(recordType: ICloudConstants.themeRecordType)
            record?.setObject(NSNumber(value: false), forKey: ICloudConstants.fieldIsOpen)
            record?.setObject(NSString(string: themeName), forKey: ICloudConstants.fieldThemeName)
            record?.setObject(NSNumber(value: false), forKey: ICloudConstants.fieldExamPassed)
            
            self.database.save(record!, completionHandler: { (_, _) in
                completion(true)
            })
        }
    }
    
    static func createThemesIfNeeded(themesName: [String], completion: @escaping ([ThemeInfo],Error?) -> Void) {
        var themesNameSet = Set(themesName)       
        func pinStarsInfo(to themesInfo: [ThemeInfo]) {
            ICloudProvider.starsInfo(completion: { (starsInfo, error) in
                guard error == nil else {
                    completion(themesInfo, error)
                    return
                }
                
                for themeInfo in themesInfo {
                    let currentThemeStarsInfo = starsInfo.filter({ (starInfo) -> Bool in
                        return starInfo.themeName == themeInfo.themeName
                    })
                    
                    let starsCount = currentThemeStarsInfo.map({ (starInfo) -> Int in
                        return starInfo.starsCount
                    })
                    
                    var totalCount = 0
                    
                    for starCount in starsCount {
                        totalCount += starCount
                    }
                    
                    themeInfo.starsCount = totalCount
                }
                
                completion(themesInfo, nil)
            })
        }
        
        ICloudProvider.themes { (themesInfo, error) in
            guard error == nil else {
                completion([], error)
                return
            }
            
            var themesInfo: [ThemeInfo] = themesInfo ?? []

            let names = themesInfo.map({ (info) -> String in
                return info.themeName
            })
            
            themesNameSet.subtract(names)
            
            if !themesNameSet.isEmpty {
                var records = [CKRecord]()
                
                for name in themesNameSet {
                    let record = CKRecord(recordType: ICloudConstants.themeRecordType)
                    record.setObject(NSNumber(value: false), forKey: ICloudConstants.fieldIsOpen)
                    record.setObject(NSNumber(value: false), forKey: ICloudConstants.fieldExamPassed)
                    record.setObject(NSString(string: name), forKey: ICloudConstants.fieldThemeName)
                    
                    records.append(record)
                }
                
                let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
                
                operation.modifyRecordsCompletionBlock = { (savedRecords, _, error) in
                    guard let savedRecords = savedRecords else {
                        pinStarsInfo(to: themesInfo)
                        return
                    }
                    print(savedRecords.count)
                    
                    themesInfo.append(contentsOf: ICloudProvider.makeListOfInfo(with: savedRecords))
                    
                    pinStarsInfo(to: themesInfo)
                }
                
                database.add(operation)
            } else {
                pinStarsInfo(to: themesInfo)
            }
        }
    }
    
    static func examPassed(themeName: String, completion: @escaping (Error?) -> ()) {
        ICloudProvider.theme(themeName: themeName) { (record, error) in
            if error != nil {
                completion(error)
                return
            }
            
            if record == nil {
                completion(nil)
                return
            }
            
            setupRecord(record, recordType: ICloudConstants.themeRecordType, key: ICloudConstants.fieldExamPassed, value: 1, completion: completion)
        }
    }
    
    static func themePurchased(themeName: String, completion: @escaping (Error?) -> ()) {
        ICloudProvider.theme(themeName: themeName) { (record, error) in
            if error != nil {
                completion(error)
                return
            }
            
            if record == nil {
                completion(nil)
                return
            }
            
            setupRecord(record, recordType: ICloudConstants.themeRecordType, key: ICloudConstants.fieldIsOpen, value: 1, completion: completion)
        }
    }
    
    static func themesPurchased(themesNames: [String], completion: @escaping ([String]) -> ()) {
        var themesNames = themesNames
        
        ICloudProvider.themesRecords { (records, error) in
            guard let records = records else {
                completion(themesNames)
                return
            }
            
            var purchasedRecords = [CKRecord]()
            
            for record in records {
                if let themeName = record.value(forKey: ICloudConstants.fieldThemeName) as? String {
                    if let index = themesNames.firstIndex(of: themeName) {
                        record.setObject(NSNumber(value: true), forKey: ICloudConstants.fieldIsOpen)
                        purchasedRecords.append(record)
                        
                        themesNames.remove(at: index)
                    }
                }
            }
            
            let operation = CKModifyRecordsOperation(recordsToSave: purchasedRecords, recordIDsToDelete: nil)
            
            operation.modifyRecordsCompletionBlock = { (_, _, error) in
                completion(themesNames)
            }
            
            database.add(operation)
        }
    }
    
    static func removeAllThemes(completion: @escaping (Error?) -> ()) {
        ICloudProvider.themesRecords { (records, error) in
            guard error == nil, let records = records else {
                completion(error)
                return
            }
            
            let recordsIds = records.map({ (record) -> CKRecord.ID in
                return record.recordID
            })
            
            if recordsIds.isEmpty {
                completion(nil)
                return
            }
            
            let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordsIds)
            
            operation.modifyRecordsCompletionBlock = { (_, deletedIds, error) in
            }
            
            operation.completionBlock = {
                completion(nil)
            }
            
            database.add(operation)
        }
    }
    
    static func experienceChanged(experience: Int, completion: @escaping (Error?) -> ()) {
        ICloudProvider.user(completion: { (record, error) in
            if error != nil {
                completion(error)
                return
            }
            
            var record = record
            
            if record == nil {
                record = CKRecord(recordType: ICloudConstants.usersRecordType)
            }
            
            setupRecord(record, recordType: ICloudConstants.usersRecordType, key: ICloudConstants.fieldExperience, value: experience, completion: completion)
        })
    }
    
    static func addExperience(experience: Int, completion: @escaping (Error?) -> ()) {
        ICloudProvider.user(completion: { (record, error) in
            if error != nil {
                completion(error)
                return
            }
            
            var record = record
            
            if record == nil {
                record = CKRecord(recordType: ICloudConstants.usersRecordType)
            }
            
            var count = 0
            
            if let oldCount = record?.value(forKey: ICloudConstants.fieldExperience) as? Int {
                count = oldCount
            }
            
            count += experience
            
            setupRecord(record, recordType: ICloudConstants.usersRecordType, key: ICloudConstants.fieldExperience, value: count, completion: completion)
        })
    }
    
    static func setupRecord(_ record: CKRecord?, recordType: String, key: String, value: Int, completion: @escaping (Error?) -> ()) {
        
        if let oldCount = record?.value(forKey: key) as? Int {
            if oldCount > value {
                return
            }
        }
        
        record!.setObject(NSNumber(value: value), forKey: key)
        
        self.database.save(record!, completionHandler: { (_, error) in
            completion(error)
        })
    }
}
