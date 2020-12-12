//
//  LanguageView.swift
//  EnglishForBeginners
//
//  Created by Sergey Aleksandrov on 04/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

class LanguageView: UIView {    
    
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageContainerView.layer.borderColor = AppColors.flagBorderColor.cgColor
        imageContainerView.layer.borderWidth = 5
    }
}
