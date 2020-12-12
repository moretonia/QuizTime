//
//  StringProtocol+Extensions.swift
//  EnglishForBeginners
//
//  Created by Sergey Aleksandrov on 09/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation

extension StringProtocol {
    
    var firstUppercased: String {
        guard let first = first else {
            return ""
        }
        return String(first).uppercased() + dropFirst()
    }
}
