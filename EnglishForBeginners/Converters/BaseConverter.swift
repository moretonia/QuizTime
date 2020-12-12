//
//  BaseConverter.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 01/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation

class BaseConverter {
    
    class StructuresForParsing {
        struct Theme: Codable {
            var id: Int16
            var name: String
            var imageName: String
            var opened: Bool?
            var topics: [Topic]?
        }
        
        struct Topic: Codable {
            var name: String
            var imageName: String
            var vocabularyItemIds: [String]
        }
        
        struct VocabularyItem: Codable {
            var id: String
            var word: String
            var transcription: String
            var imageName: String?
        }
        
        struct NativeWord: Codable {
            var id: String
            var word: String
        }
    }
}
