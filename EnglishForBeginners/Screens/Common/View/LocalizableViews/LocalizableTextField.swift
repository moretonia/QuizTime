//
//  LocalizableTextField.swift
//  EnglishForBeginners
//
//  Created by Sergey Aleksandrov on 14/05/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

class LocalizableTextField: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let localizationKey = placeholder {
            placeholder = localizationKey.localizedWithCurrentLanguage()
        }
    }
    
}
