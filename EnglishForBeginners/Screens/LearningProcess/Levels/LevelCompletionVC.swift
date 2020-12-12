//
//  LevelCompletionVC.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 27/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit
import ORCommonCode_Swift

class LevelCompletionVC: BaseVC {
    @IBOutlet weak var viewStarsContainer: UIView!
    @IBOutlet weak var viewNewRank: UIView!
    @IBOutlet weak var viewExperienceInfoContainer: UIView!
    
    @IBOutlet weak var labelNewRankName: UILabel!
    
    @IBOutlet weak var labelEarnedExperience: UILabel!
    @IBOutlet weak var labelNewRankExperience: UILabel!
    @IBOutlet weak var quizImageView: UIImageView!

    @IBOutlet weak var teacherView: UIView!
    @IBOutlet weak var teacherImageView: UIImageView!
    
    weak var viewExperienceInfo: ExperienceInfoView!
    weak var starsView: StarsView!
    
    var stars: Int = 0
    var experience: Int = 0
    var topic: Topic?
    
    var isExamCompletion = false
    var starsWereAnimated = false

    var displayedAd = false
    
    // MARK: - ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if (stars == 0) {
            animateStars()
        } else {
            showTeacher()
        }
    }

    // MARK: - Prepare UI
    
    func prepareView() {
        
        let oldOverallExperience = ProfileManager.getOverallExperience()
        let newOverallExperience = oldOverallExperience + experience
        
        ProfileManager.saveExperience(experience: newOverallExperience, difference: experience)
        
        let oldRank = RankCalculator(experience: oldOverallExperience).rank
        let newRankCalculator = RankCalculator(experience: newOverallExperience)
        let newRank = newRankCalculator.rank
        
        if oldRank == newRank {
            updateExperienceInfo(with: newRankCalculator)
        } else {
            updateNewRankView(with: newRankCalculator)
        }
        
        viewStarsContainer.isHidden = isExamCompletion
        quizImageView.isHidden = !isExamCompletion
        
        prepareForAnimation()
        
        if experience > 0 {
            let experienceText = String(format: "xp".localizedWithCurrentLanguage(), experience)
            let expirienceAttributedString = NSMutableAttributedString(string: experienceText, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .medium)])
            if let numberRange = experienceText.range(of: "\(experience)") {
                let range = NSRange(numberRange, in: experienceText)
                expirienceAttributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 20, weight: .bold), range: range)
            }
            if let plusRange = experienceText.range(of: "+") {
                let range = NSRange(plusRange, in: experienceText)
                expirienceAttributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 20, weight: .bold), range: range)
            }
            labelEarnedExperience.attributedText = expirienceAttributedString
        } else {
            labelEarnedExperience.text = ""
        }
    }
    
    func prepareExperienceLabel() {
        if experience > 0 {
            let experienceText = String(format: "xp".localizedWithCurrentLanguage(), experience)
            let expirienceAttributedString = NSMutableAttributedString(string: experienceText, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .medium)])
            if let numberRange = experienceText.range(of: "\(experience)") {
                let range = NSRange(numberRange, in: experienceText)
                expirienceAttributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 20, weight: .bold), range: range)
            }
            if let plusRange = experienceText.range(of: "+") {
                let range = NSRange(plusRange, in: experienceText)
                expirienceAttributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 20, weight: .bold), range: range)
            }
            labelEarnedExperience.attributedText = expirienceAttributedString
        } else {
            labelEarnedExperience.text = ""
        }
    }
    
    func prepareForAnimation() {
        if !isExamCompletion {
            starsView = StarsView.or_loadFromNib(containerToFill: viewStarsContainer) 
            starsView.setStarCount(stars, animated: true)
            starsView.imageViews.forEach { $0.layer.opacity = 0 }
        }
    }

    func showTeacher() {
        if (isExamCompletion) {
            teacherImageView.image = UIImage(named: "teacher_three_stars")
            AudioManager.shared.playQuizResultSound(stars: 3)
        } else {
            if (stars == 1) {
                teacherImageView.image = UIImage(named: "teacher_one_star")
            } else if (stars == 2) {
                teacherImageView.image = UIImage(named: "teacher_two_stars")
            } else if (stars == 3) {
                teacherImageView.image = UIImage(named: "teacher_three_stars")
            }
            AudioManager.shared.playQuizResultSound(stars: stars)
        }

        or_dispatch_in_main_queue_after(2.5) { [weak self] in
            if let sSelf = self {
                sSelf.teacherView.isHidden = true
                sSelf.animateStars()
            }
        }
    }
    
    func animateStars() {
        guard !starsWereAnimated else {
            return
        }
        
        starsWereAnimated = true
        
        if !isExamCompletion, stars != 0 {
            let viewsToAnimate = starsView.imageViews.or_limitedBySize(stars)
            let starsAnimator = StarsAnimator(views: viewsToAnimate, scale: 15, singleDuration: 0.6)
            starsAnimator.animate()
            or_dispatch_in_main_queue_after(0.6 * Double(stars)) { [weak self] in
                if let sSelf = self {
                    sSelf.displayedAd = true
                    AdManager.shared.showInterstitial(in: sSelf, onClose: nil)
                }
            }
        }
    }
    
    func updateExperienceInfo(with rankCalculator: RankCalculator) {
        let viewExperienceInfo = ExperienceInfoView.or_loadFromNib(containerToFill: viewExperienceInfoContainer) 
        
        let colorPack = ExperienceInfoView.ColorPack(rankColor: AppColors.completionRankColor, currentExperienceColor: .white, filledProgressColor: .white, emptyProgressColor: AppColors.completionEmptyProgressColor, experienceToNextColor: AppColors.completionExperienceToNextRankColor, otherColor: AppColors.completionOtherColor)
        
        viewExperienceInfo.updateColors(with: colorPack)
        viewExperienceInfo.update(with: rankCalculator)
        
        self.viewExperienceInfo = viewExperienceInfo
    }
    
    func updateNewRankView(with rankCalculator: RankCalculator) {
        viewNewRank.isHidden = false
        viewExperienceInfoContainer.isHidden = true
        
        labelNewRankName.text = rankCalculator.rank.title.capitalized
        labelNewRankExperience.text = "\(rankCalculator.experience)"
    }

    // MARK: - Actions
    
    @IBAction func okPressed(_ sender: Any) {
        if (!displayedAd) {
            displayedAd = true
            AdManager.shared.showInterstitial(in: self) { [weak self] in
                self?.popToController(with: TopicsViewController.self)
            }
        } else {
            popToController(with: TopicsViewController.self)
        }
    }
    
    @IBAction func sharePressed(_ sender: Any) {
        if topic != nil {
            AnalyticsHelper.logEventWithParameters(event: .Lesson_Finish_Share, themeId: topic?.theme?.name, topicId: topic?.name, typeOfLesson: nil, starsCount: nil, language: nil)
        }
        
        let isNewRankAchieved = !viewNewRank.isHidden
        
        var description: String = ""
        
        if isNewRankAchieved {
            description = String(format: "new-rank-share".localizedWithCurrentLanguage(), labelNewRankName.text!)
        } else if isExamCompletion {
            description = String(format: "experience-share".localizedWithCurrentLanguage(), experience)
        } else if case 1...3 = stars {
            description = String(format: "\(stars)-star\(stars > 1 ? "s" : "")-share".localizedWithCurrentLanguage(), experience)
        }
        
        FBSharer().shareUserResults(fromVC: self, link: URL(string: "https://itunes.apple.com/gb/app/learn-model-english/id1367918761?mt=8"), quote: description)
        // changed ru to gb on 21/7/19
    }
    
    // MARK: - Public

    func setInfo(stars: Int, experience: Int) {
        self.stars = stars
        self.experience = experience
    }
    
}
