//
//  AnalyticsHelper.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 13/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation
import ORCoreData

class AnalyticsHelper {
    
    fileprivate static func getSecondsFromSessionStart() -> TimeInterval? {
        guard let sessionStartDate = UserDefaultsManager.shared.currentSessionStartTime else {
            return nil
        }
        
        return Date().timeIntervalSince(sessionStartDate as Date)
    }
    
    static func getTimeFromSessionStart() -> String? {
        guard let secondsFromStart = getSecondsFromSessionStart() else {
            return nil
        }
        
        return secondsFromStart.or_durationStringShortWithSeconds()
    }
    
    static func updateSessionStartTimeIfNeeded(_ newStartTime: Date?) {
        
        if let newDate = newStartTime {
            if let oldDate = UserDefaultsManager.shared.currentSessionStartTime {
                if abs(oldDate.timeIntervalSince(newDate)) > 60 * 60 {
                    UserDefaultsManager.shared.currentSessionStartTime = newDate
                }
                return
            }
            UserDefaultsManager.shared.currentSessionStartTime = newDate
        }
    }
    
    static func logEventWithParameters(event: AnalyticsEvent, themeId: String? = nil, topicId: String? = nil, typeOfLesson: LessonType? = nil, starsCount: Int? = nil, language: NativeLanguage? = nil) {
        
        let uid = prepareId(with: themeId, topicId: topicId, lessonType: typeOfLesson)
        
        switch event {
        case .ME_Profile_Opened, .ME_Theme_Opened, .ME_Lesson_Started, .ME_Exam_Started:
            createOrUpdateEventLogWithParameters(event.rawValue, uid: uid, date: Date())
        default:
            break
        }
        
        let parameters = parametersComplier(event: event, themeId: themeId, topicId: topicId, typeOfLesson: typeOfLesson, starsCount: starsCount, language: language)
        
        FlurryAnalytics.logEvent(event, parameters: parameters)
    }
    
    static func parametersComplier(event: AnalyticsEvent, themeId: String? = nil, topicId: String? = nil, typeOfLesson: LessonType? = nil, starsCount: Int? = nil, language: NativeLanguage? = nil) -> [String : Any] {
        var parameters = [String : Any]()
        
        if let timeFromEventParameter = getTimeFromStartEventPair(currentEvent: event, themeId: themeId, topicId: topicId, lessonType: typeOfLesson) {
            parameters[timeFromEventParameter.key] = timeFromEventParameter.value
        }
        
        if let themeId = themeId {
            parameters[AnalyticsParameter.Theme_ID.rawValue] = themeId
        }
        
        if let topicId = topicId {
            parameters[AnalyticsParameter.Topic_ID.rawValue] = topicId
        }
        
        if let typeOfLesson = typeOfLesson {
            parameters[AnalyticsParameter.Type_Of_Lesson.rawValue] = typeOfLesson.englishTitle
        }
        
        if let starsCount = starsCount {
            if event == .ME_Exam_Finished {
                parameters[AnalyticsParameter.Rate_Of_Exam.rawValue] = starsCount
            } else if event == .ME_Lesson_Finished {
                parameters[AnalyticsParameter.Rate_Of_Lesson.rawValue] = starsCount
            }
        }
        
        if let language = language {
            parameters[AnalyticsParameter.Type_Of_Language.rawValue] = language.title
        }
        
        return parameters
    }
    
    static func getTimeFromStartEventPair(currentEvent: AnalyticsEvent, themeId: String?, topicId: String?, lessonType: LessonType?) -> (key: String, value: String)? {        
        var timeFromStartEvenPair: (key: String, value: String)?
        
        switch currentEvent {
        case .Profile_Leaderboard_Opened, .Profile_Purchases_Restored, .Profile_Rate_Restored, .Profile_Share_Produced, .Profile_Language_Сhoiced, .Profile_AboutUs_Opened:
            if let timeString = HistoryOfTracking.getTimeFromEventStartToDate(.ME_Profile_Opened, uid: "", date: Date())?.or_durationStringShortWithSeconds() {
                timeFromStartEvenPair = (AnalyticsParameter.Time_From_Profile_Opened.rawValue, timeString)
            }
        case .ME_Lesson_Started:
            let uid = prepareId(with: themeId, topicId: nil, lessonType: nil)
            if let timeString = HistoryOfTracking.getTimeFromEventStartToDate(.ME_Theme_Opened, uid: uid, date: Date())?.or_durationStringShortWithSeconds() {
                timeFromStartEvenPair = (AnalyticsParameter.Time_From_Theme_Opened.rawValue, timeString)
            }
        case .ME_Lesson_Outed, .ME_Lesson_Finished, .Lesson_Finish_Share:
            let uid = prepareId(with: themeId, topicId: topicId, lessonType: lessonType)
            if let timeString = HistoryOfTracking.getTimeFromEventStartToDate(.ME_Lesson_Started, uid: uid, date: Date())?.or_durationStringShortWithSeconds() {
                timeFromStartEvenPair = (AnalyticsParameter.Time_From_Lesson_Started.rawValue, timeString)
            }
        case .ME_Exam_Outed, .ME_Exam_Finished:
            let uid = prepareId(with: themeId, topicId: nil, lessonType: nil)
            if let timeString = HistoryOfTracking.getTimeFromEventStartToDate(.ME_Exam_Started, uid: uid, date: Date())?.or_durationStringShortWithSeconds() {
                timeFromStartEvenPair = (AnalyticsParameter.Time_From_Exam_Started.rawValue, timeString)
            }
        default:
            if let timeString = getTimeFromSessionStart() {
                timeFromStartEvenPair = (AnalyticsParameter.Time_From_Session_Start.rawValue, timeString)
            }
        }
        
        return timeFromStartEvenPair
    }
    
    static func prepareId(with themeId: String?, topicId: String?, lessonType: LessonType?) -> String {
        var uid = ""
        
        if let themeId = themeId {
            uid += themeId
        }
        
        if let topicId = topicId {
            uid += topicId
        }
        
        if let lessonType = lessonType {
            uid += lessonType.rawValue
        }
        
        return uid
    }
    
    static func createOrUpdateEventLogWithParameters(_ eventName: String, uid: String, date: Date) {
        ORCoreDataSaver.sharedInstance.saveData({ (localContext, cancelSaving) -> Void in
            if var fullList = HistoryOfTracking.mr_findAll(in: localContext) as? [HistoryOfTracking]  {
                while fullList.count > 100 {
                    
                    fullList = fullList.sorted{a, b in a.eventDate!.compare(b.eventDate! as Date) == .orderedAscending}
                    fullList.last?.mr_deleteEntity()
                    fullList.removeLast()
                }
            }
            
            let eventList = HistoryOfTracking.mr_find(byAttribute: "uid", withValue: uid, in: localContext) as! [HistoryOfTracking]
            
            var isFound: Bool = false
            
            for event in eventList {
                if event.eventName == eventName {
                    event.eventDate = date
                    event.uid = uid
                    event.eventName = eventName
                    isFound = true
                    break
                }
            }
            
            if !isFound {
                let event = HistoryOfTracking.mr_createEntity(in: localContext)
                event?.eventDate = date
                event?.uid = uid
                event?.eventName = eventName
            }
        }, success: { () -> Void in
        })
    }
}
