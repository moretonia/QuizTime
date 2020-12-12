//
//  StarsAnimator.swift
//  EnglishForBeginners
//
//  Created by Sergey Aleksandrov on 30/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

struct StarsAnimator {
    
    let views: [UIView]
    let duration: TimeInterval
    let scale: Float
  
    init(views: [UIView], scale: Float, singleDuration: TimeInterval) {
        self.views = views
        self.duration = singleDuration
        self.scale = scale
    }
    
    func animate() {        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [createScaleAnimation(), createOpacityAnimation()]
        animationGroup.duration = duration
        
        var beginTime = CACurrentMediaTime()
        
        for view in views {
            CATransaction.begin()
            animationGroup.beginTime = beginTime
            CATransaction.setCompletionBlock{
                view.layer.opacity = 1
            }
            view.layer.add(animationGroup, forKey: "star")
            beginTime = animationGroup.beginTime + duration
            CATransaction.commit()
        }
    }
    
    func createScaleAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = scale
        animation.toValue = 1
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        return animation
    }
    
    func createOpacityAnimation() -> CABasicAnimation {
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0.2
        animation.toValue = 0.7
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        return animation
    }
}
