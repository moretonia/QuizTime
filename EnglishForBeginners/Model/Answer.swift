//
//  Answer.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 02/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation

class Question: Answer {
    var learningCoef: Int = 0
    var wasAnsweredCorrectLastTime: Bool = false
    var canSkip: Bool = false
    
    var answers: [Answer]?
}

class Answer: Hashable {
    var hashValue: Int {
        if let imageName = self.imageName {
            return word.hashValue ^ imageName.hashValue
        } else {
            return word.hashValue
        }
    }

    static func ==(lhs: Answer, rhs: Answer) -> Bool {
        return lhs.word == rhs.word
    }
    
    var word: String
    var imageName: String?
    var translation: String?
    
    init(word: String, imageName: String?, translation: String?) {
        self.word = word
        self.imageName = imageName
        self.translation = translation
    }
}
