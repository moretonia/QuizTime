//
//  TypeTheWordKeyboardView.swift
//  EnglishForBeginners
//
//  Created by Vyacheslav Khlichkin on 17/04/2020.
//  Copyright © 2020 Omega-R. All rights reserved.
//

import SnapKit
import UIKit

class TypeTheWordKeyboardView: UIView {
    var keyboardButtonsArray: [UIButton] = []
    
    private lazy var outerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 0.0
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var row1StackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 0.0
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var row2StackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
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
        outerStackView.addArrangedSubview(row1StackView)
        outerStackView.addArrangedSubview(row2StackView)
        addSubview(outerStackView)
        
        for index in 1...12 {
            
            let containerView = UIView(frame: .zero)
            containerView.backgroundColor = .clear
            
            let button = UIButton(type: .custom)
            button.titleLabel?.font = .boldSystemFont(ofSize: 18)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .systemTeal
            button.layer.cornerRadius = 8
            button.layer.masksToBounds = true
            
            containerView.addSubview(button)
            
            if index <= 6 {
                row1StackView.addArrangedSubview(containerView)
            } else {
                row2StackView.addArrangedSubview(containerView)
            }
            
            keyboardButtonsArray.append(button)
        }
    }
    
    private func setupConstraints() {
        outerStackView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(self).priority(.required)
        }
        
        for button in keyboardButtonsArray {
            guard let superview = button.superview else { continue }
            button.snp.makeConstraints { make in
                make.edges.equalTo(superview).inset(2).priority(.required)
            }
        }
    }
    
    func configure(for question: Question) {
        let length = question.word.count
        
        guard length <= 12 else { fatalError() }
        
        var keys = Array(question.word)
        
        keys.append(contentsOf: Array(randomString(length: 12 - length)))
        keys.shuffle()
        
        for (index, button) in keyboardButtonsArray.enumerated() {
            let title = String(keys[index]).uppercased()
            button.setTitle(title, for: .normal)
        }
    }
    
    private func randomString(length: Int = 1) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
}
