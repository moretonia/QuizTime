//
//  EnglishTextField.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 21/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

class EnglishTextField: LocalizableTextField {

    override var textInputMode: UITextInputMode? {
        let language = "en"
        
        for activeInputMode in UITextInputMode.activeInputModes {
            if activeInputMode.primaryLanguage?.contains(language) == true {
                return activeInputMode
            }
        }
        
        return super.textInputMode
    }
    
}
