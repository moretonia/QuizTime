//
//  VocabularyConverter.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 28/02/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation
import ORCoreData

class VocabularyConverter: BaseConverter {
    
    static func dataToItems(_ data: Data, entityFinderAndCreator: ORCoreDataEntityFinderAndCreator) throws -> [VocabularyItem] {
        
        do {
            let tempItems = try JSONDecoder().decode([StructuresForParsing.VocabularyItem].self, from: data)
            var items = [VocabularyItem]()
            
            for tempItem in tempItems {
                items.append(findOrCreateItem(with: tempItem, entityFinderAndCreator: entityFinderAndCreator))
            }
            
            return items
        } catch {
            throw ConvertError.InvalidData
        }
    }
    
    
    static func dataToTranslations(_ data: Data, entityFinderAndCreator: ORCoreDataEntityFinderAndCreator) throws -> [NativeWord] {
        do {
            let tempWords = try JSONDecoder().decode([StructuresForParsing.NativeWord].self, from: data)
            var items = [NativeWord]()
            
            for tempWord in tempWords {
                items.append(findOrCreateNativeWord(with: tempWord, entityFinderAndCreator: entityFinderAndCreator))
            }
            
            return items
        } catch {
            throw ConvertError.InvalidData
        }
    }
    
    static func findOrCreateItem(with tempItem: StructuresForParsing.VocabularyItem, entityFinderAndCreator: ORCoreDataEntityFinderAndCreator) -> VocabularyItem {
        let item = entityFinderAndCreator.findOrCreateEntityOfType(VocabularyItem.self, byAttribute: Keys.id, withValue: tempItem.id)
        item.transcription = tempItem.transcription
        item.word = tempItem.word.firstUppercased
        item.imageName = tempItem.imageName
        
        return item
    }
    
    static func findOrCreateNativeWord(with tempWord: StructuresForParsing.NativeWord, entityFinderAndCreator: ORCoreDataEntityFinderAndCreator) -> NativeWord {
        let item = entityFinderAndCreator.findOrCreateEntityOfType(NativeWord.self, byAttribute: Keys.id, withValue: tempWord.id)
        item.word = tempWord.word.firstUppercased
        
        return item
    }
}
