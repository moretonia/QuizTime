//
//  FlurryAnalytics.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 13/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation
import Flurry_iOS_SDK

typealias FlurryParametersType = [String: Any]

enum AnalyticsEvent: String {
    case ME_Mainscreen_Opened
    case ME_Profile_Opened
    case Profile_Leaderboard_Opened
    case Profile_Purchases_Restored
    case Profile_Rate_Restored
    case Profile_Share_Produced
    case Profile_Language_Сhoiced
    case Profile_AboutUs_Opened
    
    case ME_Theme_Opened
    case ME_Theme_Bought
    case ME_Lesson_Started
    case ME_Lesson_Outed
    
    case ME_Lesson_Finished
    case Lesson_Finish_Share
    
    case ME_Exam_Started
    case ME_Exam_Outed
    case ME_Exam_Finished
    case ME_Dictionary_Opened
}

enum AnalyticsParameter: String {
    case Type_Of_Experience
    case Type_Of_Language
    
    case Theme_ID
    case Topic_ID
    case Type_Of_Lesson
    case Rate_Of_Lesson
    
    case Rate_Of_Exam
    
    case Time_From_Session_Start
    case Time_From_Profile_Opened
    case Time_From_Theme_Opened
    case Time_From_Lesson_Started
    case Time_From_Exam_Started
}

class FlurryAnalytics {
    
    static func logEvent(_ event: AnalyticsEvent, parameters: FlurryParametersType? = nil) {
        var parameters = parameters ?? FlurryParametersType()
        
        let currentRank = ProfileManager.getUserRank()
        
        parameters[AnalyticsParameter.Type_Of_Experience.rawValue] = currentRank.englishTitle
        
        if isFlurryActive {
            Flurry.logEvent(event.rawValue, withParameters: parameters)
        } else {
            print(parameters)
        }
    }
    
    static func logEventTimedFromSessionStart(event: AnalyticsEvent, parameters: FlurryParametersType? = nil) {
        var parameters = parameters ?? FlurryParametersType()
        
        parameters[AnalyticsParameter.Time_From_Session_Start.rawValue] = AnalyticsHelper.getTimeFromSessionStart()
        logEvent(event, parameters: parameters)
    }
}
