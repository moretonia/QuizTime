//
//  DictionaryCVCell.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 07/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

class DictionaryCVCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.alpha = self.isHighlighted ? 0.5 : 1
            }
        }
    }
}
