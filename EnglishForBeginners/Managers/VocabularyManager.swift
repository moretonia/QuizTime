//
//  VocabularyManager.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 27/02/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation
import ORCoreData

typealias VocabularyItemsResponseBlock = (([VocabularyItem]?) -> Void)

class VocabularyManager: BaseManager {
    
    static func vocabularyItems(with idList: [String], themeName: String, completion: @escaping VocabularyItemsResponseBlock) {
        
        let items = findVocabularyItems(with: idList)
        
        if idList.count > items.count {
            guard let data = VocabularyManager.dataFromAsset(with: ContentPath.vocabularyItemsPathPrefix + themeName) else {
                completion(nil)
                return
            }
            
            ORCoreDataSaver.sharedInstance.saveData({ (localContext, cancelSaving) in
                do {
                    let entityFinderAndCreator = ORCoreDataEntityFinderAndCreator(localContext)
                    let items = try VocabularyConverter.dataToItems(data, entityFinderAndCreator: entityFinderAndCreator)
                    try addNativeWords(themeName: themeName, items: items, entityFinderAndCreator: entityFinderAndCreator)
                } catch {
                    cancelSaving = true
                    completion(nil)
                }
            }, success: {
                let items = self.findVocabularyItems(with: idList)
                guard items.count == idList.count else {
                    completion(nil)
                    return
                }
                
                completion(items)
            })
        } else if needUpdateNativeWordsFor(vocabularyItems: items) {
            ORCoreDataSaver.sharedInstance.saveData({ (localContext, cancelSaving) in
                do {
                    let entityFinderAndCreator = ORCoreDataEntityFinderAndCreator(localContext)
                    let items = findVocabularyItems(with: idList, entityFinderAndCreator: entityFinderAndCreator)
                    try addNativeWords(themeName: themeName, items: items, entityFinderAndCreator: entityFinderAndCreator)
                } catch {
                    cancelSaving = true
                    completion(nil)
                }
            }, success: {
                let items = self.findVocabularyItems(with: idList)
                guard items.count == idList.count else {
                    completion(nil)
                    return
                }
                completion(items)
            })
        } else {
            completion(items)
        }
    }
    
    fileprivate static func findVocabularyItems(with idList: [String]) -> [VocabularyItem] {
        var items = [VocabularyItem]()
        
        for id in idList {
            guard let item = VocabularyItem.mr_findFirst(byAttribute: Keys.id, withValue: id) else {
                print("Item with id: \(id) does not exist")
                break
            }
            items.append(item)
        }
        
        return items
    }
    
    fileprivate static func findVocabularyItems(with idList: [String], entityFinderAndCreator: ORCoreDataEntityFinderAndCreator) -> [VocabularyItem] {
        var items = [VocabularyItem]()
        
        for id in idList {
            guard let item = entityFinderAndCreator.findEntityOfType(VocabularyItem.self, byAttribute: Keys.id, withValue: id) else {
                print("Item with id: \(id) does not exist")
                break
            }
            items.append(item)
        }
        
        return items
    }
    
    
    fileprivate static func unarchiveNativeWords(themeName: String, entityFinderAndCreator: ORCoreDataEntityFinderAndCreator) throws -> [NativeWord] {
        guard let language = UserDefaultsManager.shared.userLanguage, let data = VocabularyManager.dataFromAsset(with: ContentPath.translationsPathPrefix + language + "-" + themeName) else {
            return []
        }
        
        do {
            let nativeWords = try VocabularyConverter.dataToTranslations(data, entityFinderAndCreator: entityFinderAndCreator)
            return nativeWords
        } catch {
            throw ConvertError.InvalidData
        }
    }
    
    fileprivate static func link(vocabularyItems items: [VocabularyItem], withTranslations translations: [NativeWord]) {
        var translations = translations
        
        for item in items {
            let id = item.id!
            guard let translationIndex = translations.firstIndex(where: { (word) -> Bool in
                word.id == id
            }) else {
                return
            }
            
            item.nativeWord = translations.remove(at: translationIndex)
        }
    }
    
    fileprivate static func addNativeWords(themeName: String, items: [VocabularyItem], entityFinderAndCreator: ORCoreDataEntityFinderAndCreator) throws {
        let nativeWords = try self.unarchiveNativeWords(themeName: themeName, entityFinderAndCreator: entityFinderAndCreator)
        self.link(vocabularyItems: items, withTranslations: nativeWords)
    }

    fileprivate static func needUpdateNativeWordsFor(vocabularyItems items: [VocabularyItem]) -> Bool {
        for item in items {
            if item.nativeWord == nil {
                return true
            }
        }
        return false
    }
    
    static func removeAllNativeWords(completion: @escaping () -> ()) {
        ORCoreDataSaver.sharedInstance.saveData({ (localContext, cancelSaving) in
            ORCoreDataRemover.truncateAllOfTypes([NativeWord.self], inContext: localContext)
        }, success: {
            completion()
        })
    }
}
