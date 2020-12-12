//
//  ProfileHeaderView.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 02/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

class ProfileHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var labelType: UILabel!
    @IBOutlet weak var viewLeftSeparator: UIView!
    @IBOutlet weak var viewRightSeparator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setType(_ type: ProfileSectionType) {
        set(icon: type.image, title: type.title)
    }
    
    func set(icon: UIImage?, title: String?) {
        imageViewIcon.image = icon
        labelType.text = title
    }
    
    func changeContentColor(_ color: UIColor) {
        imageViewIcon.tintColor = color
        labelType.textColor = color
        viewLeftSeparator.backgroundColor = color
        viewRightSeparator.backgroundColor = color
    }
}
