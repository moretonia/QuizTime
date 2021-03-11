//
//  PackGenerator.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 17/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation

struct ThemesPack {
    var themesNames: [String]
    var creationDate: Date
    var removingDate: Date
    
    init(themesNames: [String], creationDate: Date, removingDate: Date) {
        self.themesNames = themesNames
        self.creationDate = creationDate
        self.removingDate = removingDate
    }
}

class PackGenerator {
    
    static func getOrGeneratePack(completion: @escaping (ThemesPack?) -> ()) {
        let currentDate = Date()
        
        if let removingDate = UserDefaultsManager.shared.currentThemesPackRemovingTime {
            let timeDifference = currentDate.timeIntervalSince(removingDate)
            
            if timeDifference < 0 {
                packFromUserDefaults(completion: completion)
            } else if timeDifference > Constants.timeBetweenPacks {
                newPack(completion: completion)
            } else {
                completion(nil)
            }
        } else {
            newPack(completion: completion)
        }
    }
    
    static func packFromUserDefaults(completion: @escaping (ThemesPack?) -> ()) {
        guard let themes = UserDefaultsManager.shared.currentThemesPackThemesNames, let creationDate = UserDefaultsManager.shared.currentThemesPackCreationTime, let removingDate = UserDefaultsManager.shared.currentThemesPackRemovingTime else {
            completion(nil)
            return
        }
        
        ICloudProvider.checkICloudAvailability { (available) in
            if available {
                let pack = ThemesPack(themesNames: themes, creationDate: creationDate, removingDate: removingDate)
                completion(pack)
            } else {
                completion(nil)
            }
        }
    }
    
    static func removeCurrentPack() {
        UserDefaultsManager.shared.currentThemesPackCreationTime = nil
        UserDefaultsManager.shared.currentThemesPackThemesNames = nil
        UserDefaultsManager.shared.currentThemesPackRemovingTime = Date()
    }
    
    static func newPack(completion: @escaping (ThemesPack?) -> ()) {
        ICloudProvider.closedThemes { (themesInfo, error) in
            guard error == nil, themesInfo.count >= 3 else {
                completion(nil)
                return
            }
            
            var shaffledThemes = themesInfo.map({ (info) -> String in
                return info.themeName
            })
            
            let shaffledThemesSet = Set(shaffledThemes)
            shaffledThemes = Array(shaffledThemesSet)
            
            shaffledThemes.shuffle()
            
            var indexesForRemoving = [Int]()
            
            for (index, shaffledTheme) in shaffledThemes.enumerated() {
                let theme = Theme.mr_findFirst(byAttribute: Keys.name, withValue: shaffledTheme)
                
                if theme?.opened == true || theme == nil {
                    indexesForRemoving.append(index)
                }
            }
            
            indexesForRemoving = indexesForRemoving.sorted(by: >)
            
            for index in indexesForRemoving {
                shaffledThemes.remove(at: index)
            }
            
            shaffledThemes = shaffledThemes.or_limitedBySize(3)
            
            if shaffledThemes.count < 3 {
                completion(nil)
                return
            }
            
            let randomLifeTime = arc4random_uniform(UInt32(Constants.maxPackLifeTime - Constants.minPackLifeTime)) + UInt32(Constants.minPackLifeTime)
            
            let creationDate = Date()
            let removingDate = creationDate.addingTimeInterval(TimeInterval(randomLifeTime))
            
            let themePack = ThemesPack(themesNames: shaffledThemes, creationDate: creationDate, removingDate: removingDate)
            UserDefaultsManager.shared.currentThemesPackCreationTime = themePack.creationDate
            UserDefaultsManager.shared.currentThemesPackRemovingTime = themePack.removingDate
            UserDefaultsManager.shared.currentThemesPackThemesNames = themePack.themesNames
            
            completion(themePack)
        }
    }
}
