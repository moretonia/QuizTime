//
//  QuestionProtocol.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 19/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation
import UIKit

protocol QuestionProtocol: class {
    var viewController: UIViewController? {get}
    
    var question: Question! {get set}
    
    var attemptsCount: Int {get set}
    var selectionHandler: (Bool) -> () {get set}
    var verifyHandler: () -> () {get set}
    var verifyResultsHandler: () -> () {get set}
    var startSpeechRecognitionHandler: () -> () {get set}

    func selectedWord() -> String
    func changeState(isCorrect: Bool, correctAnswer: Answer?)
    
    func superViewDidAppeared()
}
