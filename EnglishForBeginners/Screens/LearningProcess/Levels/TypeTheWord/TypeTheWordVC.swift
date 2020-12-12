//
//  TypeWordVC.swift
//  EnglishForBeginners
//
//  Created by Vyacheslav Khlichkin on 15/04/2020.
//  Copyright © 2020 Omega-R. All rights reserved.
//

import RxCocoa
import RxRelay
import RxSwift
import UIKit

class TypeTheWordVC: BaseLevelVC {
    @IBOutlet weak var outerStackView: UIStackView!
    @IBOutlet weak var validityIndicatorStackView: UIStackView!
    @IBOutlet var answerView: TypeTheWordAnswerView!
    @IBOutlet var keyboardView: TypeTheWordKeyboardView!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet weak var validityIndicator: ValidityIndicatorView!
    
    private lazy var answerRelay: BehaviorRelay<String> = BehaviorRelay(value: "")
    private lazy var buttonsRelay: BehaviorRelay<[UIButton]> = BehaviorRelay(value: [])
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        setupConstraints()
        setupBingings()
    }
    
    private func setupSubviews() {
        keyboardView.configure(for: question)
        // TODO: Localize
        deleteButton.setTitle("Delete".localizedWithCurrentLanguage(), for: .normal)
        outerStackView.setCustomSpacing(16, after: answerView)
    }
    
    private func setupConstraints() {}
    
    private func setupBingings() {
        // Do any additional setup after loading the view.
        
        for button in keyboardView.keyboardButtonsArray {
            button.rx.tap.asSignal()
                .map { button.title(for: .normal) }
                .compactMap { $0 }
                .asDriver(onErrorJustReturn: "")
                .drive(onNext: { [unowned self] title in
                    
                    guard self.answerRelay.value.count < self.question.word.count else { return }
                    
                    self.answerRelay.accept(self.answerRelay.value + title)
                    var buttons = self.buttonsRelay.value
                    buttons.append(button)
                    self.buttonsRelay.accept(buttons)
                    button.alpha = 0.0
                    button.isEnabled = false
                })
                .disposed(by: disposeBag)
        }
                
        deleteButton.rx.tap.asDriver()
            .drive(onNext: { [unowned self] _ in
                
                let buttons = self.buttonsRelay.value
                
                if let button = buttons.last {
                    button.alpha = 1.0
                    button.isEnabled = true
                    self.buttonsRelay.accept(buttons.dropLast(1))
                    self.answerRelay.accept(String(self.answerRelay.value.dropLast(1)))
                }
            })
            .disposed(by: disposeBag)
        
        answerRelay.asDriver()
            .drive(onNext: { [unowned self] answer in
                self.answerView.configure(for: self.question, answer: answer)
                self.selectionHandler(answer.count == self.question.word.count)
            })
            .disposed(by: disposeBag)
    }
    
    // Must contain the answer once user tap verify button
    override func selectedWord() -> String {
        return answerRelay.value
    }
    
    override func changeState(isCorrect: Bool, correctAnswer: Answer?) {
        let correctIndicator = getCorrectValidityIndicator(isCorrect: isCorrect, correctAnswer: correctAnswer)
        animateVerifying(isCorrect: isCorrect, indicator: correctIndicator)

    }
    
    override func getSelectedValidityIndicator() -> ValidityIndicatorView? {
        
        return self.validityIndicator
    }
    
    override func getCorrectValidityIndicator(isCorrect: Bool, correctAnswer: Answer?) -> ValidityIndicatorView? {
        
        return self.validityIndicator
    }

}
