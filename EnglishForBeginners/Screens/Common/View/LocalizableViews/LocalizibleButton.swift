//
//  LocalizibleButton.swift
//  EnglishForBeginners
//
//  Created by Sergey Aleksandrov on 14/05/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

class LocalizableButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let localizationKey = currentTitle {
            setTitle(localizationKey.localizedWithCurrentLanguage(), for: .normal)
        }
    }
}
