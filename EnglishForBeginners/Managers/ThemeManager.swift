//
//  ThemeManager.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 27/02/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation
import ORCoreData
import CoreData

typealias ThemeListResponseBlock = (([Theme]?) -> Void)
typealias ThemeResponseBlock = ((Theme?) -> Void)

class ThemeManager: BaseManager {
    
    static func themesNames() -> [String] {
        guard let themes = Theme.mr_findAll() as? [Theme] else {
            return []
        }
        
        let names = themes.map { (theme) -> String in
            return theme.name!
        }
        
        return names
    }
    
    static func themeListFromAsset(completion: @escaping ThemeListResponseBlock) {
        
        guard let data = ThemeManager.dataFromAsset(with: ContentPath.themeListJsonName) else {
            completion(nil)
            return
        }
        
        ORCoreDataSaver.sharedInstance.saveData({ (localContext, cancelSaving) in
            do {
                let entityFinderAndCreator = ORCoreDataEntityFinderAndCreator(localContext)
                
                let themes = try ThemeConverter.dataToThemes(data, entityFinderAndCreator: entityFinderAndCreator)
                
                let themesNames = themes.map({ (theme) -> String in
                    return theme.name!
                })
                
                self.removeUselessThemes(themesNames, context: localContext)
                
                addTranslationsToThemesIfNeeded(themesList: themes, entityFinderAndCreator: entityFinderAndCreator)
            } catch {
                cancelSaving = true
                completion(nil)
            }
        }, success: {
            guard let themes = Theme.mr_findAllSorted(by: "id", ascending: true) as? [Theme] else {
                completion(nil)
                return
            }
            completion(themes)
        })
    }
    
    static func themeList(completion: @escaping ThemeListResponseBlock) {
        ORCoreDataSaver.sharedInstance.saveData({ (localContext, _) in
            let entityFinderAndCreator = ORCoreDataEntityFinderAndCreator(localContext)
            
            guard let themesList = Theme.mr_findAll(in: localContext) as? [Theme] else {
                completion([])
                return
            }
            
            
            addTranslationsToThemesIfNeeded(themesList: themesList, entityFinderAndCreator: entityFinderAndCreator)
        }) {
            completion([])
        }
    }
    
    static func theme(with name: String, completion: @escaping ThemeResponseBlock) {
        guard let theme = Theme.mr_findFirst(byAttribute: Keys.name, withValue: name) else {
            completion(nil)
            return
        }
        
        if let topicsCount = theme.topics?.count, topicsCount > 0 {
            ORCoreDataSaver.sharedInstance.saveData({ (localContext, _) in
                let entityFinderAndCreator = ORCoreDataEntityFinderAndCreator(localContext)
                addTranslationsToTopicsIfNeeded(theme: theme, entityFinderAndCreator: entityFinderAndCreator)
            }) {
                completion(theme)
            }
            return
        }
        
        guard let data = ThemeManager.dataFromAsset(with: ContentPath.themesPathPrefix + name) else {
            print("There is no json files with this name: \(name)" )
            completion(theme)
            return
        }
        
        ORCoreDataSaver.sharedInstance.saveData({ (localContext, cancelSaving) in
            let entityFinderAndCreator = ORCoreDataEntityFinderAndCreator(localContext)
            do {
                let theme = try ThemeConverter.dataToTheme(data, entityFinderAndCreator: ORCoreDataEntityFinderAndCreator(localContext))
                addTranslationsToTopicsIfNeeded(theme: theme, entityFinderAndCreator: entityFinderAndCreator)
            } catch {
                cancelSaving = true
                completion(nil)
            }
            
        }, success: {
            DispatchQueue.main.async(execute: {
                guard let theme = ORCoreDataEntityFinderAndCreator(ThemeManager.defaultContext).findEntityOfType(Theme.self, byAttribute: Keys.name, withValue: name) else {
                    completion(nil)
                    return
                }
                completion(theme)
            })
        })
    }
    
    static func addTranslationsToThemesIfNeeded(themesList: [Theme], entityFinderAndCreator: ORCoreDataEntityFinderAndCreator) {
        if needUpdateNativeWordsFor(themes: themesList) {
            do {
                
                let nativeWords = try unarchiveNativeWords(themeName: nil, entityFinderAndCreator: entityFinderAndCreator)
                
                link(items: themesList, withTranslations: nativeWords)
            } catch {
            }
        }
    }
    
    static func addTranslationsToTopicsIfNeeded(theme: Theme, entityFinderAndCreator: ORCoreDataEntityFinderAndCreator) {
        if needUpdateNativeWordsFor(topics: theme.convertedTopics) {
            do {
                guard let theme = entityFinderAndCreator.findEntityOfType(Theme.self, byAttribute: Keys.id, withValue: theme.id) else {
                    return
                }
                
                let topics = theme.convertedTopics
                
                let nativeWords = try unarchiveNativeWords(themeName: theme.name!, entityFinderAndCreator: entityFinderAndCreator)
                
                link(items: topics, withTranslations: nativeWords)
            } catch {
            }
        }
    }
    
    fileprivate static func needUpdateNativeWordsFor(themes items: [Theme]) -> Bool {
        for item in items {
            if item.nativeWord == nil {
                return true
            }
        }
        return false
    }
    
    fileprivate static func needUpdateNativeWordsFor(topics items: [Topic]) -> Bool {
        for item in items {
            if item.nativeWord == nil {
                return true
            }
        }
        return false
    }
    
    
    fileprivate static func unarchiveNativeWords(themeName: String?, entityFinderAndCreator: ORCoreDataEntityFinderAndCreator) throws -> [NativeWord] {
        var path = ""
        
        if let themeName = themeName {
            path = ContentPath.themesPathPrefix + themeName
        } else {
            path = ContentPath.themeListJsonName
        }
        
        guard let language = UserDefaultsManager.shared.userLanguage, let data = ThemeManager.dataFromAsset(with: path + "-" + language) else {
            return []
        }
        
        do {
            let nativeWords = try VocabularyConverter.dataToTranslations(data, entityFinderAndCreator: entityFinderAndCreator)
            return nativeWords
        } catch {
            throw ConvertError.InvalidData
        }
    }
    
    fileprivate static func link(items: [Theme], withTranslations translations: [NativeWord]) {
        var translations = translations
        
        for item in items {
            let id = item.id
            guard let translationIndex = translations.firstIndex(where: { (word) -> Bool in
                word.id == String(id)
            }) else {
                return
            }
            
            item.nativeWord = translations.remove(at: translationIndex)
        }
    }
    
    fileprivate static func link(items: [Topic], withTranslations translations: [NativeWord]) {
        var translations = translations
        
        for item in items {
            let id = item.name!
            guard let translationIndex = translations.firstIndex(where: { (word) -> Bool in
                word.id == id
            }) else {
                return
            }
            
            item.nativeWord = translations.remove(at: translationIndex)
        }
    }
    
    static func buyThemes(_ themesName: [String], completion: @escaping () -> ()) {
        ORCoreDataSaver.sharedInstance.saveData({ (localContext, cancelSaving) in
            for themeName in themesName {
                let theme = ORCoreDataEntityFinderAndCreator(localContext).findEntityOfType(Theme.self, byAttribute: "name", withValue: themeName)
                theme?.opened = true
            }
        }) {
            completion()
        }
    }
 
    static func starType(of theme: Theme) -> StarType {
        var type = StarType.empty

        let starCount = theme.starsCount
        
        var atLeastOneStar: Bool = true
        var atLeastTwoStars: Bool = true
        
        if theme.convertedTopics.isEmpty {
            atLeastOneStar = false
            atLeastTwoStars = false
        }
        
        for topic in theme.convertedTopics {
            if topic.starsSet.count < 4 {
                atLeastOneStar = false
                atLeastTwoStars = false
                break
            }
            
            for starsInfo in topic.starsSet {
                atLeastOneStar = atLeastOneStar && starsInfo.starCount > 0
                atLeastTwoStars = atLeastTwoStars && starsInfo.starCount > 1
            }
        }
        
        if atLeastOneStar {
            type = .bronze
        }
        
        if atLeastTwoStars {
            type = .silver
        }
        
        switch starCount {
        //case 50..<58:
        case 50..<75:
            if type < .bronze {
                type = .bronze
            }
        //case 58..<64:
        case 75..<100:
            type = .silver
        //case let x where x >= 64:
        case let x where x >= 100:
            type = .gold
        default:
            break
        }

        return type
    }
    
    // MARK: - iCloud
    
    static func updateThemesFromICloud(completion: @escaping ThemeListResponseBlock, errorHandler: @escaping (Error) -> ()) {
        ICloudSaver.createThemesIfNeeded(themesName: themesNames(), completion: { (themesInfo, error) in
            ORCoreDataSaver.sharedInstance.saveData({ (localContext, cancelSaving) in
                if error != nil, let themes = Theme.mr_findAll() as? [Theme] {
                    let themesName = themes.map({ (theme) -> String in
                        return theme.name!
                    })
                    
                    for themeName in themesName {
                        if let theme = ORCoreDataEntityFinderAndCreator(localContext).findEntityOfType(Theme.self, byAttribute: Keys.name, withValue: themeName) {
                            theme.iCloudStarsCount = 0
                        }
                    }
                } else {
                    for info in themesInfo {
                        if let theme = ORCoreDataEntityFinderAndCreator(localContext).findEntityOfType(Theme.self, byAttribute: Keys.name, withValue: info.themeName) {
                            theme.updateTheme(with: info)
                        }
                    }
                }
            }, success: {
                guard let themes = Theme.mr_findAllSorted(by: "id", ascending: true) as? [Theme] else {
                    completion(nil)
                    return
                }
                
                completion(themes)
            })
        })
    }
    
    static func updateStarsFromICloud(themeName: String, completion: @escaping (Error?) -> ()) {
        ICloudProvider.starsInfo(themeName: themeName, completion: { (starsInfo, error) in
            guard error == nil else {
                completion(error)
                return
            }
            LearningProgressManager.addStars(from: starsInfo, completion: {
                completion(nil)
            })
        })
    }
    
    // MARK: -
    
    static fileprivate func removeUselessThemes(_ names: [String], context: NSManagedObjectContext) {
        guard var themes = Theme.mr_findAll() as? [Theme] else {
            return
        }
        themes = themes.filter { (theme) -> Bool in
            return theme.name == nil || !names.contains(theme.name!)
        }
        
        for theme in themes {
            theme.mr_deleteEntity(in: context)
        }
    }
}
