//
//  LocalizableLabel.swift
//  EnglishForBeginners
//
//  Created by Sergey Aleksandrov on 14/05/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

class LocalizableLabel: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let localizationKey = text {
            text = localizationKey.localizedWithCurrentLanguage()
        }
    }
}

