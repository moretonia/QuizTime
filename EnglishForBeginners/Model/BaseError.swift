//
//  BaseError.swift
//  EnglishForBeginners
//
//  Created by Sergey Aleksandrov on 13/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

class BaseError: NSError {

    init(domain: String, code: Int, localizationPrefix: String, prettyString: String, customDescription: String? = nil) {
        let localizedFailureReasonKey = "\(localizationPrefix)-failure-reason-\(code)"
        let localizedDescriptionKey = "\(localizationPrefix)-description-\(code)"
        
        
        let localizedFailureReason = localizedFailureReasonKey.localized()
        let localizedDescription = localizedDescriptionKey.localized()
        
        var dict = [String : Any]()
        
        if !localizedFailureReason.isEmpty && localizedFailureReason != localizedFailureReasonKey {
            dict[NSLocalizedFailureReasonErrorKey] = localizedFailureReason
        }
        
        if let customDescription = customDescription {
            dict[NSLocalizedDescriptionKey] = customDescription
        } else if !localizedDescription.isEmpty && localizedDescription != localizedDescriptionKey {
            dict[NSLocalizedDescriptionKey] = localizedDescription
        }
        
        if dict.isEmpty {
            dict[NSLocalizedDescriptionKey] = "\(prettyString) \(code)"
        }
        
        super.init(domain: domain, code: code, userInfo: dict)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
