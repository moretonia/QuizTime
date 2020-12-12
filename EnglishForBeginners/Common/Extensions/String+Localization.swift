//
//  String+Localization.swift
//  EnglishForBeginners
//
//  Created by Nikita Egoshin on 4/6/18.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation

extension String {
    
    func localized(_ locale: Locale! = nil) -> String {
        guard nil != locale else {
            return NSLocalizedString(self, comment: "")
        }
        
        let resourse = locale.languageCode
        let alternateResourse = locale.identifier.replacingOccurrences(of: "_", with: "-")
        
        if let path = Bundle.main.path(forResource: resourse, ofType: "lproj") ?? Bundle.main.path(forResource: alternateResourse, ofType: "lproj"), let languageBundle = Bundle(path: path) {
            return languageBundle.localizedString(forKey: self, value: self, table: nil)
        }
        
        return self
    }
    
    func localizedWithCurrentLanguage() -> String {
        guard let languageString = UserDefaultsManager.shared.userLanguage, let language = NativeLanguage(rawValue: languageString) else {
            return localized()
        }
        
        return localized(language.currentLocale)
    }
}
