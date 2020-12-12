//
//  ProfileOtherCell.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 02/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

class ProfileOtherCell: UITableViewCell {

    @IBOutlet weak var imageViewType: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imageViewCorner: UIImageView!
    
    @IBOutlet weak var viewTopSeperator: UIView!
    @IBOutlet weak var viewBottomSeparator: UIView!
    @IBOutlet weak var imageTypeWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupSeparatorsVisibility()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func update(with image: UIImage?, title: String) {
        imageViewType.image = image
        labelTitle.text = title
    }
    
    func setupSeparatorsVisibility(top: Bool = true, bottom: Bool = false) {
        viewTopSeperator.isHidden = !top
        viewBottomSeparator.isHidden = !bottom
    }
}
