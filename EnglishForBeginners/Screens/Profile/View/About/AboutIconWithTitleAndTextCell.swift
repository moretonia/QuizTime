//
//  AboutIconWithTitleAndTextCell.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 18/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

class AboutIconWithTitleAndTextCell: UITableViewCell {
    
    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
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

    func update(with icon: UIImage?, title: String, text: NSAttributedString) {
        imageViewIcon.image = icon
        labelTitle.text = title
        labelText.attributedText = text
    }
}
