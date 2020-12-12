//
//  AboutSimpleTextCell.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 18/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

class AboutSimpleTextCell: UITableViewCell {

    @IBOutlet weak var labelText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func update(with attributedString: NSMutableAttributedString) {
        
        labelText.attributedText = attributedString
    }
}
