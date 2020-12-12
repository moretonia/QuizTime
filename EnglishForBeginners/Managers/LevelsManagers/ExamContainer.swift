//
//  ExamContainer.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 22/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

class ExamContainer: BaseQuestionContainer, QuestionsProvider, QuestionsValidator {

    var theme: Theme
    
    var allTypes: [LessonType] = [.association, .pronunciation, .spelling, .translation]
    
    var studyProgress: Float {
        return Float(currentCoef) / Float(roundNumbers)
    }
    
    var roundNumbers: Int {
        return ExamConfig.questionCount
    }
    
    init(theme: Theme) {
        self.theme = theme
        super.init()
        lessonType = randomLessonType()
    }
    
    // MARK: -
    
    func randomLessonType(_ exceptType: LessonType? = nil) -> LessonType {
        var allTypes = self.allTypes
        
        if let exceptType = exceptType, let index = allTypes.firstIndex(of: exceptType) {
            allTypes.remove(at: index)
        }
        
        allTypes.shuffle()
        
        return allTypes.first!
    }
    
    // MARK: - Filling questions stack
    
    func fillQuestionsStack(completion: @escaping () -> ()) {
        guard let themeName = theme.name else {
            return
        }
        
        var wordsIds = [String]()
        
        for topic in theme.convertedTopics {
            wordsIds.append(contentsOf: topic.wordsIds)
        }
        
        VocabularyManager.vocabularyItems(with: wordsIds, themeName: themeName) { [weak self] (items) in
            guard let items = items else {
                return
            }
            
            guard let sself = self else {
                return
            }
            
            sself.fillQuestionsStack(with: items)
            completion()
        }
    }
    
    func fillQuestionsStack(with words: [VocabularyItem]) {
        var shuffledWords = words
        shuffledWords.shuffle()
        
        var shuffledWordsWithoutDuplicates = [VocabularyItem]()
        
        for word in shuffledWords {
            if let wordName = word.word {
                let index = shuffledWordsWithoutDuplicates.firstIndex(where: { (question) -> Bool in
                    return question.word == wordName || question.nativeWord?.word == word.nativeWord?.word
                })
                
                if index == nil {
                    shuffledWordsWithoutDuplicates.append(word)
                } else {
                    shuffledWordsWithoutDuplicates.remove(at: index!)
                    continue
                }
            }
        }
        
        for word in shuffledWordsWithoutDuplicates {
            if let wordName = word.word {
                if questionsStack.count < roundNumbers {
                    let question = Question(word: wordName, imageName: word.imageName, translation: word.nativeWord?.word)
                    questionsStack.append(question)
                }
                
                let answer = Answer(word: wordName, imageName: word.imageName, translation: word.nativeWord?.word)
                answersList.append(answer)
            }
        }
    }
    
    // MARK: - QuestionsProvider
    
    var canSkipQuestion: Bool = false
    
    var title: String {
        return "Quiz"
    }
    
    func nextQuestion() -> (question: Question?, levelProgress: Float?) {
        guard studyProgress < 1.0 else {
            return (nil, 1)
        }
        
        guard mistakesCounter < ExamConfig.maximumMistakesAmount else {
            return (nil, 0)
        }
        
        lessonType = randomLessonType(lessonType)
        
        currentStep += 1
        
        fillCurrentAnswerPack()
        
        return (currentQuestion, nil)
    }
    
    func skipAndGetNextQuestion() -> (question: Question?, levelProgress: Float?) {
        return (nil, nil)
    }

    // MARK: - QuestionsValidator

    func saveProgress(_ answer: String) -> Float {
        let isCorrect = checkAnswer(answer).isCorrect
        
        if !isCorrect {
            mistakesCounter += 1
        }
        
        currentCoef += 1
        
        return studyProgress
    }

    func checkAnswer(_ answer: String) -> (isCorrect: Bool, correctAnswer: Answer) {
        let isCorrect = currentQuestion.word.lowercased() == answer.lowercased()
        
        wasPreviousAnswerCorrect = isCorrect
        
        return (isCorrect, findAnswer(with: currentQuestion.word)!)
    }
    
    func getProgress() -> Float {
        return studyProgress
    }
}
