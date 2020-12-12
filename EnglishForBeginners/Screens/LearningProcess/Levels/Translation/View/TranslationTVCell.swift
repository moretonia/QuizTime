//
//  TranslationTVCell.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 19/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit
import ORCommonUI_Swift

class TranslationTVCell: UITableViewCell {
    
    @IBOutlet weak var viewCorrect: ValidityIndicatorView!
    @IBOutlet weak var labelWord: UILabel!
    
    @IBOutlet weak var viewContent: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        didChangeSelection(selected)
    }
    
    // MARK: -
    
    private func didChangeSelection(_ selected: Bool) {
        viewContent.backgroundColor = selected ? AppColors.selectedCellColor : AppColors.notSelectedCellColor
        labelWord.textColor = selected ? AppColors.selectedText : AppColors.notSelectedText
    }
}
