//
//  LessonActionButton.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 19/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit
import ORCommonUI_Swift

class LessonActionButton: ORRoundRectButton {

    enum ButtonState {
        case disabledVerification
        case verification
        
        var alpha: CGFloat {
            switch self {
            case .disabledVerification:
                return 0.2
            default:
                return 1
            }
        }
        
        var title: String {
            switch self {
            case .disabledVerification, .verification:
                return "verify".localizedWithCurrentLanguage()
            }
        }
        
        var isEnabled: Bool {
            switch self {
            case .disabledVerification:
                return false
            default:
                return true
            }
        }
        
        var negativeState: ButtonState {
            switch self {
            case .disabledVerification:
                return .verification            
            case .verification:
                return .disabledVerification
            }
        }
        
        var backGroundColor: UIColor {
            switch self {
            case .disabledVerification, .verification:
                return AppColors.actionButtonVerificationColor
            }
        }
    }
    
    var buttonState: ButtonState = .disabledVerification {
        didSet {
            backgroundColor = buttonState.backGroundColor
            isEnabled = buttonState.isEnabled
            alpha = buttonState.alpha
            setTitle(buttonState.title, for: .normal)
        }
    }
    
    override var clipsToBounds: Bool {
        get {
            return super.clipsToBounds
        }
        set {
            super.clipsToBounds = false
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.alpha = self.isHighlighted ? 0.5 : self.buttonState.alpha
                self.alpha = self.isHighlighted ? 0.5 : self.buttonState.alpha
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        prepareShadow()
    }
    
    // MARK: -
    
    func prepareShadow() {
        layer.shadowColor = UIColor(31, 83, 109).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 1
    }
    
}
