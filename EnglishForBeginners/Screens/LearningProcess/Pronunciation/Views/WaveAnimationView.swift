//
//  WaveAnimationView.swift
//  EnglishForBeginners
//
//  Created by Sergey Aleksandrov on 21/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

class WaveAnimationView: UIView {
    
    @IBInspectable
    open var color: UIColor = UIColor(69, 89, 99).withAlphaComponent(0.3)
    
    private var firstWaveLayer: CAShapeLayer!
    private var secondWaveLayer: CAShapeLayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setupCircleLayers()
    }

    // MARK: - Animation
    
    private func createCircleLayer(color: UIColor) -> CAShapeLayer {
        let circularPath = UIBezierPath(arcCenter: .zero, radius: frame.width / 3, startAngle: 0, endAngle: 2 * .pi, clockwise: true).cgPath
        let layer = CAShapeLayer()
        layer.path = circularPath
        layer.fillColor = color.cgColor
        layer.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        return layer
    }
    
    open func startAnimation() {
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 2.5
        animationGroup.repeatCount = .infinity
        
        let waveAnimation = createWaveAnimation()
        let disappearingAnimation = createDisapperingAnimation()
        animationGroup.animations = [waveAnimation, disappearingAnimation]
        
        animationGroup.beginTime = CACurrentMediaTime()
        firstWaveLayer.add(animationGroup, forKey: "wave")
        animationGroup.beginTime = animationGroup.beginTime + 0.5
        secondWaveLayer.add(animationGroup, forKey: "wave")

    }
    
    open func stopAnimation() {
        firstWaveLayer.removeAllAnimations()
        secondWaveLayer.removeAllAnimations()
    }

    // MARK: - Private methods
    
    private func setupCircleLayers() {
        firstWaveLayer = createCircleLayer(color: color)
        layer.addSublayer(firstWaveLayer)
        
        secondWaveLayer = createCircleLayer(color: color)
        layer.addSublayer(secondWaveLayer)
    }
    
    private func createWaveAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 2
        animation.duration = 1.5
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        return animation
    }
    
    private func createDisapperingAnimation() -> CABasicAnimation {
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1
        animation.toValue = 0
        animation.duration = 1.5
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        return animation
    }
}
