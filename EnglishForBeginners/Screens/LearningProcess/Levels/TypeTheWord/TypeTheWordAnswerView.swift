//
//  TypeTheWordAnswerView.swift
//  EnglishForBeginners
//
//  Created by Vyacheslav Khlichkin on 17/04/2020.
//  Copyright © 2020 Omega-R. All rights reserved.
//

import SnapKit
import UIKit

class TypeTheWordAnswerView: UIView {
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0.0
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupSubviews()
        setupConstraints()
    }
    
    private func setupSubviews() {
        addSubview(stackView)
    }
    
    private func setupConstraints() {
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalTo(self)
            make.centerX.equalTo(self)
        }
    }
    
    func configure(for question: Question, answer: String) {
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        let answerChars = Array(answer)
        
        for (index, _) in question.word.enumerated() {
            
            let containerView = UIView(frame: .zero)
            containerView.backgroundColor = .clear
            containerView.translatesAutoresizingMaskIntoConstraints = false

            // TODO: replace with the circles
            let label = AnswerLetterLabel()
            label.translatesAutoresizingMaskIntoConstraints = false

            containerView.addSubview(label)
            
            label.snp.makeConstraints { make in
                make.edges.equalTo(containerView).inset(1).priority(.required)
                make.height.equalTo(label.snp.width).priority(.required)
            }
            
            containerView.snp.makeConstraints { make in
                make.height.equalTo(containerView.snp.width).priority(.required)
            }

            stackView.addArrangedSubview(containerView)
            
            if index < answerChars.count {
                label.text = String(answerChars[index])
            } else {
                label.text = ""
            }
        }
    }
}
