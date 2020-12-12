//
//  SpellingVC.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 21/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

class SpellingVC: BaseLevelVC, UITextFieldDelegate {

    @IBOutlet weak var validityIndicatorView: ValidityIndicatorView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var labelCorrectAnswer: UILabel!
    @IBOutlet weak var viewFrame: UIView!
    @IBOutlet weak var correctIndicator: ValidityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareView()
    }

    override func selectedWord() -> String {
        textField.isUserInteractionEnabled = false
        return textField.text ?? ""
    }
    
    override func changeState(isCorrect: Bool, correctAnswer: Answer?) {
        animateVerifying(isCorrect: isCorrect, indicator: validityIndicatorView, correctIndicator: correctIndicator)
        labelCorrectAnswer.text = correctAnswer?.word
        labelCorrectAnswer.isHidden = isCorrect
        correctIndicator.isHidden = isCorrect
        textField.delegate = nil
    }
    
    override func superViewDidAppeared() {
        DispatchQueue.main.async {
            self.textField.becomeFirstResponder()
        }
    }
    
    // MARK: -
    
    func prepareView() {
        textField.delegate = self
        
        viewFrame.layer.borderColor = AppColors.spellingBorderColor.cgColor
        viewFrame.layer.borderWidth = 1.0
        
        viewFrame.layer.cornerRadius = 5
    }
    
    // MARK: - Actions
    
    @IBAction func textFieldOnChange(_ sender: UITextField) {
        selectionHandler(sender.text?.isEmpty == false)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.isEmpty == false {
            verifyHandler()
        }
        return textField.resignFirstResponder()
    }
}
