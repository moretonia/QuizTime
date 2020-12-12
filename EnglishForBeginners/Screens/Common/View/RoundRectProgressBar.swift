//
//  RoundRectProgressBar.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 27/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit
import ORCommonUI_Swift
import PureLayout

class RoundRectProgressBar: ORRoundRectView {
    
    weak var filledView: ORRoundRectView?

    var progress: CGFloat = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateFilledView()
    }
    
    private func addFilledViewIfNeeded() {
        if filledView == nil {
            
            let filledView = ORRoundRectView()
            addSubview(filledView)
            filledView.frame = bounds
            filledView.frame.size.width = 0
            
            self.filledView = filledView
        }
    }
    
    func updateProgress(progress: CGFloat, animated: Bool = false, delay: TimeInterval = 0) {
        addFilledViewIfNeeded()
        self.progress = progress
        updateFilledView(animated: animated, delay: delay)
    }
    
    func setColors(filledColor: UIColor, emptyColor: UIColor) {
        addFilledViewIfNeeded()
        filledView?.backgroundColor = filledColor
        backgroundColor = emptyColor
    }
    
    private func updateFilledView(animated: Bool = false, delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
        if animated {
            UIView.animate(withDuration: 0.4, delay: delay, animations: {
                self.filledView?.frame.size.width = self.frame.width * self.progress
            })
        } else {
            filledView?.frame.size.width = frame.width * progress
        }
    }
}
