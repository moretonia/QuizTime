//
//  TimeInterval+Extended.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 13/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation

extension TimeInterval {
    
    public func or_durationComponentsWithSeconds() -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let value: TimeInterval = self < 0 ? 0 : self
        
        let days = Int(value / (60 * 60 * 24))
        let hours = Int(value / (60 * 60)) - days * 24
        let minutes = Int(value / 60) - days * 24 * 60 - hours * 60
        let seconds = Int(value.truncatingRemainder(dividingBy: 60))
        
        return (days: days, hours: hours, minutes: minutes, seconds: seconds)
    }
    
    
    func or_durationStringShortWithSeconds(daysLocalized: String = "", hoursLocalized: String = "", minutesLocalized: String = "", secondsLocalized: String = "") -> String {
        
        var result = ""
        let components = or_durationComponentsWithSeconds()
        
        if components.days > 0 { result += "\(components.days)" + daysLocalized + ":" }
        if components.hours > 0 { result += "\(components.hours)" + hoursLocalized + ":"}
        if components.minutes >= 0 { result += (components.minutes < 10 ? "0" : "") + "\(components.minutes)" + minutesLocalized + ":"}
        if components.seconds >= 0 { result += (components.seconds < 10 ? "0" : "") + "\(components.seconds)" + secondsLocalized }
        
        return result
        
    }
}
