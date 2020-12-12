//
//  QuestionsContainer.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 02/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation

class QuestionContainer: BaseQuestionContainer, QuestionsProvider, QuestionsValidator {
    var topic: Topic
    
    var title: String {
        return lessonType.message
    }
    
    var canSkipQuestion: Bool {
        return currentQuestion.canSkip
    }
    
    var studyProgress: Float {
        return Float(currentCoef) / Float(roundNumbers)
    }
    
    var roundNumbers: Int {
        let maximumCount = lessonType.roundNumbers
        var minimumCount = answersList.count * 3 + mistakesCounter
        minimumCount = minimumCount > questionsStack.count ? minimumCount : questionsStack.count
        
        return min(minimumCount, maximumCount)
    }
    
    init(topic: Topic, lessonType: LessonType) {
        self.topic = topic
        
        super.init()
        
        self.lessonType = lessonType
    }
    
    // MARK: - Filling lists
    
    func fillQuestionsStack(completion: @escaping () -> ()) {
        guard let themeName = topic.theme?.name else {
            return
        }
        
        VocabularyManager.vocabularyItems(with: topic.wordsIds, themeName: themeName) { [weak self] items in
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
        
        for word in shuffledWords {
            guard let wordName = word.word else { continue }
            
            if lessonType == .listenType || lessonType == .lookType, wordName.count > 12 {
                print("Word is too long for this lesson type")
                continue
            }
            
            let question = Question(word: wordName, imageName: word.imageName, translation: word.nativeWord?.word)
            question.canSkip = lessonType.attemptsBeforeSkipping != 0
            
            questionsStack.append(question)
            questionsList.append(question)
            
            let answer = Answer(word: wordName, imageName: word.imageName, translation: word.nativeWord?.word)
            answersList.append(answer)
            
            if questionsStack.count == lessonType.roundNumbers { return }
        }
    }
    
    func changeLearningCoef(_ correct: Bool) {
        currentCoef += 1
        
        let wordIsNotLearned = currentQuestion.learningCoef < lessonType.successfulLearningCoef
        
        if wordIsNotLearned {
            if correct {
                currentQuestion.learningCoef += 1
            } else {
                currentQuestion.learningCoef = currentQuestion.learningCoef > -1 ? currentQuestion.learningCoef - 1 : -1
                mistakesCounter += 1
            }
            
            if lessonType.multipleAttemptsAvailable {
                let questionPositionChange = !correct ? 2 : currentQuestion.wasAnsweredCorrectLastTime ? 6 : 3
                
                changeQuestionPositionInStack(to: currentStep + questionPositionChange + 1)
            }
        }
        
        currentQuestion.wasAnsweredCorrectLastTime = correct
    }
    
    func changeQuestionPositionInStack(to position: Int) {
        if position < questionsStack.count {
            questionsStack.insert(currentQuestion, at: position)
        } else {
            fillStackWithLearnedWords(questionsStack.count - position)
            questionsStack.append(currentQuestion)
        }
    }
    
    func fillStackWithLearnedWords(_ amount: Int) {
        var learnedWords = questionsList.filter { (question) -> Bool in
            question.learningCoef == lessonType.successfulLearningCoef
        }
        
        learnedWords.shuffle()
        
        let neededStackSize = questionsStack.count + amount
        
        while questionsStack.count < neededStackSize {
            questionsStack.append(learnedWords.removeFirst())
        }
    }
    
    // MARK: - QuestionsProvider
    
    func nextQuestion() -> (question: Question?, levelProgress: Float?) {
        guard studyProgress < 1.0 else {
            let learnedWords = questionsList.filter { (question) -> Bool in
                question.learningCoef == lessonType.successfulLearningCoef
            }
            
            if !questionsList.isEmpty {
                let progress = Float(learnedWords.count) / Float(questionsList.count)
                
                return (nil, progress)
            }
            
            return (nil, 0.0)
        }
        
        currentStep += 1
        
        fillCurrentAnswerPack()
        
        return (currentQuestion, nil)
    }
    
    func skipAndGetNextQuestion() -> (question: Question?, levelProgress: Float?) {
        currentQuestion.canSkip = false
        questionsStack.append(currentQuestion)
        
        return nextQuestion()
    }
    
    // MARK: - QuestionsValidator
    
    func saveProgress(_ answer: String) -> Float {
        let isCorrect = checkAnswer(answer).isCorrect
        
        changeLearningCoef(isCorrect)
        
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
