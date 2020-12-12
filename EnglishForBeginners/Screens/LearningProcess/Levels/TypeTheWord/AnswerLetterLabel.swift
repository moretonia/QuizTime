//
//  AnswerLetterLabel.swift
//  EnglishForBeginners
//
//  Created by Vyacheslav Khlichkin on 25/04/2020.
//  Copyright © 2020 Omega-R. All rights reserved.
//

import UIKit

class AnswerLetterLabel: UILabel {
    
    override init(frame: CGRect) {
         super.init(frame: frame)
         setupView()
     }

     required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
         setupView()
     }

    override func layoutSubviews() {
        super.layoutSubviews()
        let height = frame.height
        font = .boldSystemFont(ofSize: CGFloat(height / 2 + 2))
    }
    
    private func setupView() {
        backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        layer.cornerRadius = 4
        layer.masksToBounds = true
        textColor = .black
        textAlignment = .center
    }
}
