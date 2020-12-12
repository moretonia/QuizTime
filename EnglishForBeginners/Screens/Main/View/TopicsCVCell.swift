//
//  TopicsViewCollectionCell.swift
//  EnglishForBeginners
//
//  Created by Vladimir on 28.02.18.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit
import ORCommonUI_Swift

protocol TopicsCVCellDelegate: class {
    func dictionaryPressed(topicsCVCell: TopicsCVCell)
    func lessonPressed(topicsCVCell: TopicsCVCell, lessonType: LessonType)
}

class TopicsCVCell: UICollectionViewCell {
    
    @IBOutlet weak var photoView: UIImageView!
    
    @IBOutlet weak var stackViewTop: UIStackView!
    @IBOutlet weak var stackViewMiddle: UIStackView!
    @IBOutlet weak var stackViewBottom: UIStackView!
    
    @IBOutlet weak var viewControls: UIView!
    @IBOutlet weak var viewLocked: UIView!
    
    @IBOutlet weak var labelTopicName: UILabel!
    
    weak var lessonControlLookType: LessonControl!
    weak var lessonControlListenType: LessonControl!
    weak var lessonControlAssociation: LessonControl!
    weak var lessonControlTranslation: LessonControl!
    weak var lessonControlPronunciation: LessonControl!
    weak var lessonControlSpelling: LessonControl!

    var stars = Set<Stars>() {
        didSet {
            updateStars()
        }
    }
    
    lazy var lessonControls: [LessonControl] = {
        return [
            lessonControlLookType,
            lessonControlListenType,
            lessonControlAssociation,
            lessonControlTranslation,
            lessonControlPronunciation,
            lessonControlSpelling
        ]
    }()
    
    weak var delegate: TopicsCVCellDelegate?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        prepareControls()
    }
    
    func changeState(_ opened: Bool) {
        viewControls.isHidden = !opened
        viewLocked.isHidden = opened
    }
    
    // MARK: - Prepare UI
    
    private func prepareControls() {
        
        self.lessonControlLookType = loadAndSetupLessonControl(lessonType: .lookType)
        self.lessonControlListenType = loadAndSetupLessonControl(lessonType: .listenType)
        self.lessonControlAssociation = loadAndSetupLessonControl(lessonType: .association)
        self.lessonControlTranslation = loadAndSetupLessonControl(lessonType: .translation)
        self.lessonControlPronunciation = loadAndSetupLessonControl(lessonType: .pronunciation)
        self.lessonControlSpelling = loadAndSetupLessonControl(lessonType: .spelling)
        
        stackViewTop.addArrangedSubview(lessonControlLookType)
        stackViewTop.addArrangedSubview(lessonControlListenType)
      
        stackViewMiddle.addArrangedSubview(lessonControlAssociation)
        stackViewMiddle.addArrangedSubview(lessonControlTranslation)

        stackViewBottom.addArrangedSubview(lessonControlPronunciation)
        stackViewBottom.addArrangedSubview(lessonControlSpelling)
    }
    
    private func loadAndSetupLessonControl(lessonType: LessonType) -> LessonControl {
        let lessonControl = LessonControl.or_loadFromNib() 
        lessonControl.setLessonType(lessonType)
        lessonControl.addTarget(self, action: #selector(lessonControlPressed(_:)), for: .touchUpInside)
        return lessonControl
    }
    
    private func updateStars() {
        for lessonControl in lessonControls {
            let starCount = stars.filter { $0.lessonType == lessonControl.lessonType.rawValue }.first?.starCount ?? 0
            lessonControl.setStarCount(Int(starCount))
        }
    }
    
    func updateTopicName(_ name: String) {
        let attributedString = NSMutableAttributedString(string: name)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.hyphenationFactor = 0.6
        paragraphStyle.alignment = .center
        
        let fullRange = NSRange(location: 0, length: name.count)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
        
        labelTopicName.attributedText = attributedString
    }
    
    // MARK: - Actions
    
    @objc private func lessonControlPressed(_ sender: LessonControl) {
        delegate?.lessonPressed(topicsCVCell: self, lessonType: sender.lessonType)
    }
    
    @IBAction func dictionaryPressed(_ sender: Any) {
        delegate?.dictionaryPressed(topicsCVCell: self)
    }
    
}


