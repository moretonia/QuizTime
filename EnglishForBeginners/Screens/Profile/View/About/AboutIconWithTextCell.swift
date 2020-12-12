//
//  AboutIconWithTextCell.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 18/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

class AboutIconWithTextCell: UITableViewCell {

    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var labelText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        guard let languageString = UserDefaultsManager.shared.userLanguage, let language = NativeLanguage(rawValue: languageString) else {
            labelText.textAlignment = .justified
            return
        }
        labelText.textAlignment = language == .arabic ? .right : .justified
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func update(with icon: UIImage?, text: NSAttributedString) {
        imageViewIcon.image = icon
        labelText.attributedText = text
    }
    
}
