//
//
//  ThemeConverter.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 27/02/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation
import ORCoreData

class ThemeConverter: BaseConverter {
    static func dataToTheme(_ data: Data, entityFinderAndCreator: ORCoreDataEntityFinderAndCreator) throws -> Theme {
        do {
            let tempTheme = try JSONDecoder().decode(StructuresForParsing.Theme.self, from: data)
            let theme = findOrCreateTheme(with: tempTheme, entityFinderAndCreator: entityFinderAndCreator)
            return theme
        } catch {
            throw ConvertError.InvalidData
        }
    }
    
    static func dataToThemes(_ data: Data, entityFinderAndCreator: ORCoreDataEntityFinderAndCreator) throws -> [Theme] {
        do {
            let tempThemes = try JSONDecoder().decode([StructuresForParsing.Theme].self, from: data)
            var themes = [Theme]()
            
            for tempTheme in tempThemes {
                let theme = findOrCreateTheme(with: tempTheme, entityFinderAndCreator: entityFinderAndCreator)
                
                themes.append(theme)
            }
            
            return themes
        } catch {
            throw ConvertError.InvalidData
        }
    }
    
    static func findOrCreateTheme(with tempTheme: StructuresForParsing.Theme, entityFinderAndCreator: ORCoreDataEntityFinderAndCreator) -> Theme {
        let theme = entityFinderAndCreator.findOrCreateEntityOfType(Theme.self, byAttribute: Keys.name, withValue: tempTheme.name)
        theme.id = tempTheme.id
        theme.name = tempTheme.name
        theme.imageName = tempTheme.imageName
        theme.opened = theme.opened || (tempTheme.opened ?? false)
        
        guard let tempTopics = tempTheme.topics else {
            return theme
        }
        
        let topics = TopicConverter.findOrCreateTopics(with: tempTopics, entityFinderAndCreator: entityFinderAndCreator)
        
        theme.topics = NSOrderedSet(array: topics)
        
        var vocabularyItemsIds = [String]()
        
        for topic in topics {
            guard let topicItemsIds = topic.vocabularyItemIds as? [String] else {
                return theme
            }
            
            vocabularyItemsIds.append(contentsOf: topicItemsIds)
        }
        
        theme.vocabularyItemIds = vocabularyItemsIds as NSArray
        
        return theme
    }
}
