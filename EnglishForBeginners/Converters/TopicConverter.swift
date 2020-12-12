//
//  TopicConverter.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 27/02/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation
import ORCoreData

class TopicConverter: BaseConverter {
    
    static func findOrCreateTopics(with tempTopics: [StructuresForParsing.Topic], entityFinderAndCreator: ORCoreDataEntityFinderAndCreator) -> [Topic] {
        var topics = [Topic]()
        for tempTopic in tempTopics {
            topics.append(findOrCreateTopic(with: tempTopic, entityFinderAndCreator: entityFinderAndCreator))
        }
        return topics
    }
    
    static func findOrCreateTopic(with tempTopic: StructuresForParsing.Topic, entityFinderAndCreator: ORCoreDataEntityFinderAndCreator) -> Topic {
        
        let topic = entityFinderAndCreator.findOrCreateEntityOfType(Topic.self, byAttribute: Keys.name, withValue: tempTopic.name)
        topic.imageName = tempTopic.imageName
        topic.vocabularyItemIds = tempTopic.vocabularyItemIds as NSArray
        return topic
    }
}
