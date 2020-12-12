//
//  FindTheImageCVCell.swift
//  EnglishForBeginners
//
//  Created by Sergey Aleksandrov on 19/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

class FindTheImageCVCell: UICollectionViewCell {
    
    @IBOutlet weak var validityIndicatorView: ValidityIndicatorView!    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var whiteView: UIView!
    
    var isEnabled = true {
        didSet {
            if isEnabled {
                animateEnabling()
            } else {
                animateDisabling()
            }
        }
    }
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderColor = UIColor.white.cgColor
    }
    
    // MARK: - Animation
    
    func animateEnabling() {
        UIView.animate(withDuration: 0.5) {
            self.whiteView.alpha = 0
        }
    }
    
    func animateDisabling() {
        UIView.animate(withDuration: 0.35) {
            self.whiteView.alpha = 1
        }
    }
}
