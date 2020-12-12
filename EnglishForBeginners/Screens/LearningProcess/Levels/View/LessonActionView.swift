//
//  LessonActionView.swift
//  EnglishForBeginners
//
//  Created by Sergey Aleksandrov on 10/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit
import ORCommonUI_Swift

protocol LessonActionViewDelegate: class {
    func nextButtonPressed(state: LessonActionView.State)
}

class LessonActionView: UIView {

    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var resultImageView: UIImageView!   
    @IBOutlet weak var nextButton: ORCustomContentButton!    
    @IBOutlet weak var arrowImageView: UIImageView!    
    @IBOutlet weak var buttonTitleLabel: UILabel!
    
    enum State {
        case correct
        case wrong
        case skip
        case correctFinish
        case wrongFinish
        
        var title: String {
            switch self {
            case .correct, .correctFinish:
                return "correct".localizedWithCurrentLanguage()
            case .wrong, .skip, .wrongFinish:
                return "wrong".localizedWithCurrentLanguage()
            }
        }
        
        var needArrow: Bool {
            switch self {
            case .correctFinish, .wrongFinish:
                return false
            default:
                return true
            }
        }
        
        var backgroundColor: UIColor {
            switch self {
            case .correct, .correctFinish:
                return AppColors.actionViewCorrectColor
            case .wrong, .skip, .wrongFinish:
                return AppColors.actionViewWrongColor
            }
        }
        
        var icon: UIImage {
            switch self {
            case .correct, .correctFinish:
                return #imageLiteral(resourceName: "icon-correct")
            case .wrong, .skip, .wrongFinish:
                return #imageLiteral(resourceName: "icon-wrong")
            }
        }
        
        var buttonTitle: String {
            switch self {
            case .correctFinish, .wrongFinish:
                return "finish".localizedWithCurrentLanguage()
            default:
                return "next".localizedWithCurrentLanguage()
            }
        }
    }
    
    var state: State! {
        didSet {
            resultLabel.text = state.title
            resultImageView.image = state.icon
            roundedView.backgroundColor = state.backgroundColor
            arrowImageView.isHidden = !state.needArrow
            buttonTitleLabel.text = state.buttonTitle
        }
    }
    
    var enabled = true
    
    weak var delegate: LessonActionViewDelegate?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        animateArrow()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        applyRoundedCorners()
    }
    
    // MARK: - Actions
    
    @IBAction func nextButtonPressed() {
        delegate?.nextButtonPressed(state: state)
    }
    
    // MARK: -
    
    func applyRoundedCorners() {
        let path = UIBezierPath(roundedRect: roundedView.bounds,
                                byRoundingCorners:[.topLeft, .topRight],
                                cornerRadii: CGSize(width: 12, height: 12))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        roundedView.layer.mask = maskLayer
    }
    
    // MARK: - Animation
    
    func animateArrow() {
        let animation = CABasicAnimation(keyPath: "position.x")
        animation.byValue = -4
        animation.duration = 0.6
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.repeatCount = .infinity
        animation.autoreverses = true
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        arrowImageView.layer.add(animation, forKey: "arrowAnimation")
    }
}
