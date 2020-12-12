//
//  ProfileSkillCell.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 02/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

class ProfileSkillCell: UITableViewCell {

    @IBOutlet weak var labelSkillName: UILabel!
    @IBOutlet weak var labelPoints: UILabel!
    @IBOutlet weak var progressView: RoundRectProgressBar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func update(with title: String, points: Int, progress: CGFloat) {
        labelSkillName.text = title
        labelPoints.text = String(points)
        
        progressView.updateProgress(progress: progress)
        progressView.setColors(filledColor: AppColors.profileSkillFilledProgressColor, emptyColor: AppColors.profileProgressEmptyColor)
        
    }
}
