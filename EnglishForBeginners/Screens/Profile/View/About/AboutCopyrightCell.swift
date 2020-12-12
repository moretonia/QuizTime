//
//  AboutCopyrightCell.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 18/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

class AboutCopyrightCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func update(with attributedString: NSMutableAttributedString) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 5
        
        let fullRange = NSRange(location: 0, length: attributedString.length)
        
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
        attributedString.addAttribute(.foregroundColor, value: AppColors.aboutDefaultTextColor, range: fullRange)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .regular), range: fullRange)
        
        textView.attributedText = attributedString
    }
    
    // MARK: - UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        return true
    }
}
