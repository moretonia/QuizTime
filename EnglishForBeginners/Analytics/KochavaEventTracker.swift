//
//  KochavaEventTracker.swift
//  EnglishForBeginners
//
//  Created by Vyacheslav Khlichkin on 01/02/2020.
//  Copyright © 2020 Omega-R. All rights reserved.
//

import AdSupport
import Foundation

class KochavaEventTracker {
    private enum ExperienceAchivement: Int {
        case exp_1000_earned = 1000
        case exp_5000_earned = 5000
        case exp_10_000_earned = 10_000
        case exp_50_000_earned = 50_000
        case exp_100_000_earned = 100_000

        var description: String {
            switch self {
            case .exp_1000_earned:
                return "Score_1000"
            case .exp_5000_earned:
                return "Score_5000"
            case .exp_10_000_earned:
                return "Score_10000"
            case .exp_50_000_earned:
                return "Score_50000"
            case .exp_100_000_earned:
                return "Score_100000"
            }
        }
    }

    static func trackExperienceChangeIfNeeded(previousExperience: Int, currentExperience: Int) {
        if currentExperience < ExperienceAchivement.exp_1000_earned.rawValue { return }

        if previousExperience < ExperienceAchivement.exp_1000_earned.rawValue, currentExperience >= ExperienceAchivement.exp_1000_earned.rawValue {
            trackExperienceAchievementEvent(.exp_1000_earned)
            return
        }

        if previousExperience < ExperienceAchivement.exp_5000_earned.rawValue, currentExperience >= ExperienceAchivement.exp_5000_earned.rawValue {
            trackExperienceAchievementEvent(.exp_5000_earned)
            return
        }

        if previousExperience < ExperienceAchivement.exp_10_000_earned.rawValue, currentExperience >= ExperienceAchivement.exp_10_000_earned.rawValue {
            trackExperienceAchievementEvent(.exp_10_000_earned)
            return
        }

        if previousExperience < ExperienceAchivement.exp_50_000_earned.rawValue, currentExperience >= ExperienceAchivement.exp_50_000_earned.rawValue {
            trackExperienceAchievementEvent(.exp_50_000_earned)
            return
        }

        if previousExperience < ExperienceAchivement.exp_100_000_earned.rawValue, currentExperience >= ExperienceAchivement.exp_100_000_earned.rawValue {
            trackExperienceAchievementEvent(.exp_100_000_earned)
            return
        }
    }

    private static func trackExperienceAchievementEvent(_ experienceAchievement: ExperienceAchivement) {
        //guard let idfa = identifierForAdvertising() else { return }

        if let event = KochavaEvent(eventTypeEnum: .achievement) {
            event.nameString = experienceAchievement.description
            event.infoDictionary = [
                "experience": experienceAchievement.rawValue,
          //      "idfa": idfa
            ]

            KochavaTracker.shared.send(event)
        }
    }
}

extension KochavaEventTracker {
    static func identifierForAdvertising() -> String? {
        // Check whether advertising tracking is enabled
        guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled else { return nil }

        // Get and return IDFA
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
}
