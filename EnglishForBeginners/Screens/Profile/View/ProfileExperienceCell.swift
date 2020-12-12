//
//  ProfileExperienceCell.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 02/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

class ProfileExperienceCell: UITableViewCell {

    @IBOutlet weak var viewContainer: UIView!
    
    weak var viewExperienceInfo: ExperienceInfoView!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        prepareView()
    }
    
    private func prepareView() {
        
        let viewExperienceInfo = ExperienceInfoView.or_loadFromNib(containerToFill: viewContainer) 
        
        let colorPack = ExperienceInfoView.ColorPack(rankColor: AppColors.profileRankColor, currentExperienceColor: AppColors.profileCurrentExperienceColor, filledProgressColor: AppColors.profileExperienceFilledProgressColor, emptyProgressColor: AppColors.profileProgressEmptyColor, experienceToNextColor: AppColors.profileExperienceToNextColor, otherColor: AppColors.profileOtherColor)
        
        viewExperienceInfo.updateColors(with: colorPack)
        viewExperienceInfo.progressView.updateProgress(progress: 0.5)
        
        self.viewExperienceInfo = viewExperienceInfo
    }

    func update(with rankCalculator: RankCalculator) {
        viewExperienceInfo.update(with: rankCalculator)
    }
}
