//
//  BaseLevelVC.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 19/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

class BaseLevelVC: BaseVC, QuestionProtocol {

    weak var viewController: UIViewController? {
        return self
    }
    
    weak var question: Question!
    
    var attemptsCount: Int = 0
    
    var selectionHandler: (Bool) -> () = { (_) in
    }
    
    var verifyHandler: () -> () = {
    }
    
    var verifyResultsHandler: () -> () = {
    }
    
    var startSpeechRecognitionHandler = {}
    
    func selectedWord() -> String {
        fatalError("Must be overridden!")
    }
    
    func changeState(isCorrect: Bool, correctAnswer: Answer?) {
        fatalError("Must be overridden!")
    }
    
    func superViewDidAppeared() {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Animation
    
    func animateVerifying(isCorrect: Bool, indicator: ValidityIndicatorView?, correctIndicator: ValidityIndicatorView? = nil) {
        indicator?.changeState(isCorrect ? .correct : .wrong)
        correctIndicator?.changeState(.correct, delay: 0.2)
        let lastDelay: TimeInterval = correctIndicator == nil ? 0.2 : 0.4
        DispatchQueue.main.asyncAfter(deadline: .now() + lastDelay) { [weak self] in
            guard let sself = self else {
                return
            }
            sself.verifyResultsHandler()
        }
    }
    
    func getSelectedValidityIndicator() -> ValidityIndicatorView? {
        fatalError("getSelectedValidityIndicator method must be overriden")
    }
    
    func getCorrectValidityIndicator(isCorrect: Bool, correctAnswer: Answer?) -> ValidityIndicatorView? {
        fatalError("getCorrectValidityIndicator method must be overriden")
    }
}
