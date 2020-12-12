//
//  CustomHighlightButton.swift
//  EnglishForBeginners
//
//  Created by Sergey Aleksandrov on 04/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import ORCommonUI_Swift

class CustomHighlightButton: ORRoundRectButton {
    
    var defaultAlpha: CGFloat = 1.0
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        isExclusiveTouch = true
        defaultAlpha = alpha
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.alpha = self.isHighlighted ? 0.5 : self.defaultAlpha
                self.alpha = self.isHighlighted ? 0.5 : self.defaultAlpha
            }
        }
    }
    
}
