//
//  AppError.swift
//  EnglishForBeginners
//
//  Created by Sergey Aleksandrov on 13/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

enum AppErrorCode: Int {
    case requestTimedOut = 001
}

class AppError: BaseError {
    static let kErrorDomain = "appError"
    static let kLocalizationPrefix = "app-error"
    static let kPrettyString = "App Error"
    
    static func errorWithCode(_ code: AppErrorCode) -> AppError {
        return AppError(domain: kErrorDomain, code: code.rawValue,
                        localizationPrefix: kLocalizationPrefix, prettyString: kPrettyString)
    }
    
    static func errorWithCode(_ code: AppErrorCode, customDescription: String) -> AppError {
        return AppError(domain: kErrorDomain, code: code.rawValue,
                        localizationPrefix: kLocalizationPrefix, prettyString: kPrettyString, customDescription: customDescription)
    }
    
    static func defaultErrorDescriptionKey(code: AppErrorCode)  -> String {
        return "\(kLocalizationPrefix)-description-\(code.rawValue)"
    }
}
