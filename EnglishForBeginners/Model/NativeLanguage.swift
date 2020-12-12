//
//  NativeLanguage.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 26/02/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation
import UIKit

enum NativeLanguage: String {
    case french
    case german
    case spanish
    case portuguese
    case polish
    case czech
    case ukrainian
    case russian
    case arabic
    case turkish
    case hungarian
    case chineseSimplified = "chinese-simplified"
    case chineseTraditional = "chinese-traditional"
    case japanese
    case korean
    case thai
    case romanian
    
    case english
    
    var title: String {
        return self.rawValue.replacingOccurrences(of: "-", with: " ").capitalized
    }
    
    var displayName: String {
        let locale = NSLocale(localeIdentifier: identifier)
        return locale.displayName(forKey: .identifier, value: identifier)!
    }
    
    var identifier: String {
        switch self {
        case .french:
            return "fr"
        case .german:
            return "de"
        case .spanish:
            return "es"
        case .portuguese:
            return "pt"
        case .polish:
            return "pl"
        case .czech:
            return "cs"
        case .ukrainian:
            return "uk"
        case .russian:
            return "ru"
        case .arabic:
            return "ar"
        case .turkish:
            return "tr"
        case .hungarian:
            return "hu"
        case .chineseSimplified:
            return "zh_Hans"
        case .chineseTraditional:
            return "zh_Hant"
        case .japanese:
            return "ja"
        case .korean:
            return "ko"
        case .thai:
            return "th"
        case .romanian:
            return "ro"
        case .english:
            return "en"
        }
    }
    
    var image: UIImage? {
        let imageName: String
        switch self {
        case .chineseSimplified, .chineseTraditional:
            imageName = "chinese"
        default:
            imageName = self.rawValue
        }
        return UIImage(named: imageName)
    }
    
    var smallImage: UIImage? {
        var imageName: String
        switch self {
        case .chineseSimplified, .chineseTraditional:
            imageName = "chinese"
        default:
            imageName = self.rawValue
        }
        imageName += "-small"
        return UIImage(named: imageName)
    }
    
    static let allLanguages: [NativeLanguage] = [.arabic, .chineseSimplified, .chineseTraditional, .czech, .french,
                                                 .german, .hungarian, .japanese, .korean, .polish,
                                                 .portuguese, .romanian, .russian, .spanish, .thai, .turkish, .ukrainian]
    
    var currentLocale: Locale {
        switch self {
        case .arabic:
            return Locale(identifier: "ar")
        case .chineseSimplified:
            return Locale(identifier: "zh_Hans")
        case .chineseTraditional:
            return Locale(identifier: "zh_Hant")
        case .czech:
            return Locale(identifier: "cs_CZ")
        case .french:
            return Locale(identifier: "fr_FR")
        case .german:
            return Locale(identifier: "de_DE")
        case .hungarian:
            return Locale(identifier: "hu")
        case .japanese:
            return Locale(identifier: "ja_JP")
        case .korean:
            return Locale(identifier: "ko")
        case .polish:
            return Locale(identifier: "pl_PL")
        case .portuguese:
            return Locale(identifier: "pt_PT")
        case .romanian:
            return Locale(identifier: "ro_RO")
        case .russian:
            return Locale(identifier: "ru_RU")
        case .spanish:
            return Locale(identifier: "es_ES")
        case .thai:
            return Locale(identifier: "th_TH")
        case .turkish:
            return Locale(identifier: "tr")
        case .ukrainian:
            return Locale(identifier: "uk")
        case .english:
            return Locale(identifier: "en")
        }
    }
    
}
