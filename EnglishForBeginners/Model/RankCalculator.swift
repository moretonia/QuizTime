//
//  RankCalculator.swift
//  EnglishForBeginners
//
//  Created by Sergey Aleksandrov on 06/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation
import UIKit

struct RankCalculator {
    
    let experience: Int
    
    private var maximumRank: Rank {
        return .supermind
    }
    
    var isMaximumRank: Bool {
        return rank == maximumRank
    }
    
    var rank: Rank {
        return rankNumber > maximumRank.rawValue ? .supermind : Rank(rawValue: rankNumber)!
    }
    
    var nextRankExperience: Int {
        return experienceFor(rankNumber: rankNumber + 1)
    }
    
    var progress: CGFloat {
        let startRankExperience = experienceFor(rankNumber: rankNumber)
        return (CGFloat(experience - startRankExperience) / CGFloat(nextRankExperience - startRankExperience))
    }
    
    private var rankNumber: Int {
        let rank = (-375 + sqrt(375 * 375 + 4500 * Double(experience))) / 2250
        return Int(rank)
    }
    
    private func experienceFor(rankNumber: Int) -> Int {
        return 375 * rankNumber * (3 * rankNumber + 1)
    }
}
