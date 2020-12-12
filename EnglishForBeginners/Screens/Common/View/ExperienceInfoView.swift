//
//  ExperienceInfoView.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 03/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

class ExperienceInfoView: UIView {
    @IBOutlet weak var labelExperience: UILabel!
    @IBOutlet weak var progressView: RoundRectProgressBar!
    @IBOutlet weak var labelCurrentRankName: UILabel!
    @IBOutlet weak var labelCurrentExperience: UILabel!
    @IBOutlet weak var labelExperienceToNext: UILabel!
    @IBOutlet weak var imageTrophy: UIImageView!
    @IBOutlet weak var viewLeftSeparator: UIView!
    @IBOutlet weak var viewRightSeparator: UIView!
    
    struct ColorPack {
        var rankColor: UIColor
        var currentExperienceColor: UIColor
        var filledProgressColor: UIColor
        var emptyProgressColor: UIColor
        var experienceToNextColor: UIColor
        var otherColor: UIColor
    }
    
    func updateColors(with colorPack: ColorPack) {
        labelCurrentRankName.textColor = colorPack.rankColor
        labelCurrentExperience.textColor = colorPack.currentExperienceColor
        labelExperienceToNext.textColor = colorPack.experienceToNextColor
        progressView.setColors(filledColor: colorPack.filledProgressColor, emptyColor: colorPack.emptyProgressColor)
        
        imageTrophy.tintColor = colorPack.otherColor
        viewLeftSeparator.backgroundColor = colorPack.otherColor
        viewRightSeparator.backgroundColor = colorPack.otherColor
        labelExperience.textColor = colorPack.otherColor
    }
    
    func update(with rankCalculator: RankCalculator) {
        labelCurrentExperience.text = "\(rankCalculator.experience)"
        labelCurrentRankName.text = rankCalculator.rank.title.capitalized
        if rankCalculator.isMaximumRank {
            progressView.isHidden = true
            labelExperienceToNext.isHidden = true
        } else {
            progressView.updateProgress(progress: rankCalculator.progress)
            labelExperienceToNext.text = String(format: "next-level".localizedWithCurrentLanguage(), rankCalculator.nextRankExperience)
        }
        labelExperience.text = "experience".localizedWithCurrentLanguage()        
    }
    
}
