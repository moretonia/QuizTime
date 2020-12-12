//
//  ValidityIndicatorView.swift
//  EnglishForBeginners
//
//  Created by Sergey Aleksandrov on 19/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit
import ORCommonUI_Swift

class ValidityIndicatorView: ORRoundRectView {

    enum State {
        case disabled
        case wrong
        case correct
        
        var color: UIColor {
            switch self {
            case .disabled:
                return .clear
            case .wrong:
                return UIColor(242, 82, 61)
            case .correct:
                return UIColor(151, 201, 64)
            }
        }
    }    

    fileprivate var state: State = .disabled {
        didSet {
            backgroundColor = state.color
        }
    }
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        state = .disabled
    }
    
    func changeState(_ state: ValidityIndicatorView.State, delay: TimeInterval = 0, completion: ((Bool) -> Void)? = nil) {
        self.state = state
        transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        UIView.animate(withDuration: 0.4, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
            self.transform = .identity
        }, completion: completion)
    }
}
