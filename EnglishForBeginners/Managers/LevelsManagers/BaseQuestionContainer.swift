//
//  BaseQuestionContainer.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 22/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation

protocol QuestionsProvider: class {
    
    var title: String {get}
    var canSkipQuestion: Bool {get}
    var lessonType: LessonType {get}

    func fillQuestionsStack(completion: @escaping () -> ())
    func nextQuestion() -> (question: Question?, levelProgress: Float?)
    func skipAndGetNextQuestion() -> (question: Question?, levelProgress: Float?)
}

protocol QuestionsValidator: class {
    
    var mistakesCounter: Int {get}
    
    func saveProgress(_ answer: String) -> Float
    func checkAnswer(_ answer: String) -> (isCorrect: Bool, correctAnswer: Answer)
    func getProgress() -> Float
}

class BaseQuestionContainer {
    
    var lessonType: LessonType = .association
    
    var questionsList = [Question]()
    var answersList = [Answer]()
    
    var questionsStack = [Question]()
    
    var currentStep = -1
    var currentCoef = 0
    
    var mistakesCounter = 0
    
    var currentQuestion: Question {
        get {
            return questionsStack[currentStep]
        }
    }
    
    var wasPreviousAnswerCorrect: Bool = true
    
    func fillCurrentAnswerPack() {
        var answerPack = Set<Answer>()
        
        if let currentAnswer = findAnswer(with: questionsStack[currentStep].word) {
            answerPack.insert(currentAnswer)
        }
        
        if !lessonType.multipleAnswers {
            currentQuestion.answers = Array(answerPack)
            return
        }
        
        let isLastStep = currentStep + 1 >= questionsStack.count
        
        if !isLastStep {
            if let nextAnswer = findAnswer(with: questionsStack[currentStep + 1].word) {
                answerPack.insert(nextAnswer)
            }
        }
        
        var previousQuestion: Question? = nil
        
        if currentStep - 1 >= 0 && wasPreviousAnswerCorrect {
            let question = questionsStack[currentStep - 1]
            previousQuestion = question
        }
        
        var shuffledAnswersStack = answersList
        shuffledAnswersStack.shuffle()
        
        while answerPack.count < lessonType.answersPackSize {
            let answer = shuffledAnswersStack.removeFirst()
            
            if answer == previousQuestion {
                continue
            }
            
            answerPack.insert(answer)
        }
        
        var answerList = Array(answerPack)
        answerList.shuffle()
        
        currentQuestion.answers = answerList
    }
    
    func findAnswer(with word: String) -> Answer? {
        let filteredList = answersList.filter { (answer) -> Bool in
            return answer.word == word
        }
        
        return filteredList.first
    }
}
