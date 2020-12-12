//
//  LessonControl.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 13/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

class LessonControl: UIControl {
    
    @IBOutlet weak var imageViewType: UIImageView!
    @IBOutlet weak var labelType: UILabel!
    @IBOutlet weak var viewStarsContainer: UIView!
    
    var lessonType: LessonType!
    
    weak var starsView: StarsView?
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.imageViewType.alpha = self.isHighlighted ? 0.3 : 1
                self.labelType.alpha = self.isHighlighted ? 0.3 : 1
            }
        }
    }
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isExclusiveTouch = true
    }
    
    // MARK: - Public
    
    func setLessonType(_ lessonType: LessonType) {
        self.lessonType = lessonType
        imageViewType.image = lessonType.icon
        labelType.text = lessonType.title
    }
    
    func setStarCount(_ count: Int) {
        if starsView == nil {
            starsView = StarsView.or_loadFromNib(containerToFill: viewStarsContainer)
        }
        
        starsView?.setStarCount(count)
    }
}
