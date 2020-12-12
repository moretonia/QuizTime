//
//  StarsView.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 27/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

class StarsView: UIView {
    @IBOutlet weak var imageViewFirstStar: UIImageView!
    @IBOutlet weak var imageViewSecondStar: UIImageView!
    @IBOutlet weak var imageViewThirdStar: UIImageView!
    
    lazy var imageViews: [UIImageView] = [imageViewFirstStar, imageViewSecondStar, imageViewThirdStar]
    
    func setStarCount(_ count: Int, animated: Bool = false) {
        
        if count == 0 {
            for i in 1...3 {
                changeStarState(starIndex: i, filled: false, animated: animated)
            }
            return
        }
        
        for i in 1...count {
            changeStarState(starIndex: i, filled: true, animated: animated)
        }
        
        if count >= 3 {
            return
        }
        
        for i in count + 1...3 {
            changeStarState(starIndex: i, filled: false, animated: animated)
        }
    }
    
    private func changeStarState(starIndex: Int, filled: Bool, animated: Bool) {
        var imageView: UIImageView?
        
        switch starIndex {
        case 1:
            imageView = imageViewFirstStar
        case 2:
            imageView = imageViewSecondStar
        case 3:
            imageView = imageViewThirdStar
        default:
            imageView = nil
        }
        
        imageView?.image = filled ? (animated ? #imageLiteral(resourceName: "icon-star-big-filled") : #imageLiteral(resourceName: "icon-star-small-filled")) : #imageLiteral(resourceName: "icon-star-small-empty")
    }
}
