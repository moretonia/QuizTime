//
//  WordCompareHelper.swift
//  EnglishForBeginners
//
//  Created by Sergey Aleksandrov on 25/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation

struct WordCompareHelper {
    
    static func clearForCompare(_ string: String) -> String {
        var clearedString = string
        let symbolsToClear = [" ", "'", "-"]
        for symbol in symbolsToClear {
            clearedString = clearedString.replacingOccurrences(of: symbol, with: "")
        }
        return clearedString
    }
    
    static func isFuzzyEqual(_ first: String, _ second: String) -> Bool {
        let substringLenght = 1
        let threshold: Float = 0.70
        
        var equalSubstringsCount = 0
        var usedSubstringIndices = [Int]()

        let firstSubstringsCount = first.count - substringLenght + 1
        let secondSubstringsCount = second.count - substringLenght + 1
        
        for i in 0..<firstSubstringsCount {
            let startIndex = first.index(first.startIndex, offsetBy: i)
            let endIndex = first.index(startIndex, offsetBy: substringLenght)
            let firstSubstring = first[startIndex..<endIndex]
            
            for j in 0..<secondSubstringsCount {
                if !usedSubstringIndices.contains(j) {
                    let startIndex = second.index(second.startIndex, offsetBy: j)
                    let endIndex = second.index(startIndex, offsetBy: substringLenght)
                    let secondSubstring = second[startIndex..<endIndex]
                    
                    if firstSubstring == secondSubstring {
                        equalSubstringsCount += 1
                        usedSubstringIndices.append(j)
                        break
                    }
                }
            }
        }
        
        let tanimoto = Float(equalSubstringsCount) / Float(firstSubstringsCount + secondSubstringsCount - equalSubstringsCount)
        print(first + " vs " + second + ": " + "\(tanimoto)")
        return tanimoto >= threshold
    }
    
    static func isContains(_ word: String, in texts: [String]) -> Bool {
        let clearedWord = clearForCompare(word)
        for text in texts {
            print(text)
            let clearedText = clearForCompare(text)
            if clearedText.range(of: clearedWord, options: .caseInsensitive) != nil {
                return true
            }
        }
        return false
    }
    
    static func isContainsFuzzyEqual(_ word: String, in texts: [String]) -> Bool {
        let clearedWord = clearForCompare(word)
        for text in texts {
            let clearedText = clearForCompare(text)
            if isFuzzyEqual(clearedWord, clearedText) {
                return true
            }
        }
        return false
    }
}
