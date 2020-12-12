//
//  CustomHighlightButton.swift
//  EnglishForBeginners
//
//  Created by Sergey Aleksandrov on 04/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import ORCommonUI_Swift

class LocalizableCustomHighlightButton: CustomHighlightButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let localizationKey = currentTitle {
            setTitle(localizationKey.localizedWithCurrentLanguage(), for: .normal)
        }
    }
}
