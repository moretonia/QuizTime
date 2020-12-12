//
//  DictionaryDetailCell.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 12/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

protocol DictionaryDetailCellDelegate: class {
    func speakButtonPressed(dictionaryDetailCVCell: DictionaryDetailCell)
}

class DictionaryDetailCell: UIView {
    
    @IBOutlet weak var labelWord: UILabel!
    @IBOutlet weak var labelTranscription: UILabel!
    @IBOutlet weak var labelTranslation: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelPageNumber: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    weak var delegate: DictionaryDetailCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        prepareShadow()
    }
    
    func update(with word: VocabularyItem) {
        labelWord.text = word.word
        if let transcription = word.transcription {
            let attributedString = NSMutableAttributedString(string: "[\(transcription)]")
            attributedString.addAttributes([NSAttributedString.Key.kern : 1.5, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20.0, weight: .light)], range: NSRange(location: 0, length: attributedString.length))
            labelTranscription.attributedText = attributedString
        }
        
        labelTranslation.text = word.nativeWord?.word
        
        if let imageName = word.imageName {
            imageView.image = UIImage(named: imageName)
        }
    }
    
    func updatePageNumber(_ number : Int) {
        labelPageNumber.text = "-\(number)-"
    }
    
    // MARK: -
    
    private func prepareShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 16)
        layer.shadowOpacity = 0.2
    }
    
    // MARK: - Actions
    
    @IBAction func speechPressed(_ sender: Any) {
        delegate?.speakButtonPressed(dictionaryDetailCVCell: self)
    }
}
