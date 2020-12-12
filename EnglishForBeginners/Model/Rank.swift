//
//  Rank.swift
//  EnglishForBeginners
//
//  Created by Sergey Aleksandrov on 05/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

enum Rank: Int {
    case beginner = 0
    case pupil
    case student
    case connoisseur
    case outstanding
    case specialist
    case pros
    case master
    case pastMaster
    case guru
    case sage
    case enlightened
    case oracle
    case genius
    case higherMind
    case supermind
    
    private var rankString: String {
        switch self {
        case .beginner:
            return "beginner"
        case .pupil:
            return "pupil"
        case .student:
            return "student"
        case .connoisseur:
            return "connoisseur"
        case .outstanding:
            return "outstanding"
        case .specialist:
            return "specialist"
        case .pros:
            return "pro"
        case .master:
            return "master"
        case .pastMaster:
            return "magister"
        case .guru:
            return "guru"
        case .sage:
            return "sage"
        case .enlightened:
            return "enlightened"
        case .oracle:
            return "oracle"
        case .genius:
            return "genius"
        case .higherMind:
            return "higher-mind"
        case .supermind:
            return "supermind"
        }
    }
    
    var title: String {
        return rankString.localizedWithCurrentLanguage()
    }
    
    var englishTitle: String {
        return rankString.localized(NativeLanguage.english.currentLocale)
    }
}
