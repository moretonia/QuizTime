//
//  LevelsVC.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 15/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import ORCommonUI_Swift
import UIKit

class LevelsVC: BaseVC, LevelFailedDelegate, LessonActionViewDelegate, SpeechSynthesizerDelegate {
    @IBOutlet var contentView: UIView!
    @IBOutlet var progressView: RoundRectProgressBar!
    
    @IBOutlet var labelLessonTitle: UILabel!
    
    @IBOutlet var verifyButton: LessonActionButton!
    @IBOutlet var cheatsButton: UIButton!
    
    @IBOutlet var lessonActionViewContainer: UIView!
    @IBOutlet var showLessonActionConstraint: NSLayoutConstraint!
    @IBOutlet var hideLessonActionConstraint: NSLayoutConstraint!
    @IBOutlet var heartsStackView: UIStackView!
    
    // Custom content button
    @IBOutlet var viewSound: UIView!
    @IBOutlet var buttonSpeakWord: ORCustomContentButton!
    @IBOutlet var labelWord: UILabel!
    @IBOutlet var questionImageView: UIImageView!
    
    weak var pageViewController: UIPageViewController!
    var speechSynthesizer = SpeechSynthesizer()
    
    var questionProvider: QuestionsProvider!
    var questionValidator: QuestionsValidator!
    
    var topic: Topic!
    var theme: Theme!
    
    var lessonType: LessonType? = .association
    
    var viewWasAppeared = false
    
    var isUsedForExam: Bool {
        return lessonType == nil
    }
    
    var questionType: LessonType {
        return questionProvider.lessonType
    }
    
    weak var currentQuestionVC: QuestionProtocol?
    
    weak var lessonActionView: LessonActionView!
    
    // MARK: - ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cheatsButton.isHidden = !isDebug

        //AdManager.shared.requestInterstitial()
        
        setupPageViewController()
        
        startLesson()
        
        AnalyticsHelper.logEventWithParameters(event: isUsedForExam ? .ME_Exam_Started : .ME_Lesson_Started, themeId: topic?.theme?.name ?? theme.name, topicId: topic?.name, typeOfLesson: lessonType, starsCount: nil, language: nil)
        
        prepareLessonActionView()
        
        labelLessonTitle.text = questionType.message
        
        heartsStackView.isHidden = !isUsedForExam
        
        speechSynthesizer.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewWasAppeared = true
        tellChildThatViewDidAppearIfNeeded()
    }
    
    // MARK: - Prepare
    
    func prepareLessonActionView() {
        let lessonActionView = LessonActionView.or_loadFromNib(containerToFill: lessonActionViewContainer)
        lessonActionView.delegate = self
        lessonActionView.layoutIfNeeded()
        self.lessonActionView = lessonActionView
    }
    
    // MARK: -
    
    func startLesson() {
        setupProgressView()
        setupQuestionProvider()
        setupHeartsView()
    }
    
    func setupProgressView() {
        progressView.updateProgress(progress: 0.0)
        progressView.setColors(filledColor: AppColors.filledProgressViewColor, emptyColor: AppColors.emptyProgressViewColor)
        
        progressView.progress = 0.0
    }
    
    func setupHeartsView() {
        heartsStackView.arrangedSubviews.forEach { heart in
            heart.transform = .identity
            heart.alpha = 1
        }
    }
    
    func setupQuestionProvider() {
        showActivityIndicator()
        
        if let lessonType = self.lessonType {
            let questionContainer = QuestionContainer(topic: topic, lessonType: lessonType)
            
            questionProvider = questionContainer
            questionValidator = questionContainer
        } else {
            let examContainer = ExamContainer(theme: theme)
            
            questionProvider = examContainer
            questionValidator = examContainer
        }
        
        questionProvider.fillQuestionsStack { [weak self] in
            guard let sself = self else {
                return
            }
            
            let nextQuestionObject = sself.questionProvider.nextQuestion()
            
            sself.goToNextScreen(nextQuestionObject: nextQuestionObject)
            sself.hideActivityIndicator()
        }
    }
    
    func setupPageViewController() {
        let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageVC.view.clipsToBounds = false
        or_addChildViewController(pageVC, intoView: contentView)
        pageViewController = pageVC
    }
    
    func goToNextScreen(nextQuestionObject: (question: Question?, levelProgress: Float?)) {
        if let question = nextQuestionObject.question {
            setQuestionVC(question: question)
        }
        
        if let progress = nextQuestionObject.levelProgress {
            showResultScreen(result: progress)
        }
    }
    
    func setQuestionVC(question: Question) {
        labelWord.text = question.word
        
        if questionType.needToShowTitleImage, let imageName = question.imageName {
            questionImageView.image = UIImage(named: imageName)
            questionImageView.isHidden = false
        } else {
            questionImageView.isHidden = true
        }
        
        labelWord.isHidden = !questionType.needToShowWord
        
        if !questionType.isMainWordEnglish, let translation = question.translation {
            labelWord.text = translation
        }
        
        if questionType.isMainWordEnglish {
            speechSynthesizer.speak(question.word)
        }
        buttonSpeakWord.isUserInteractionEnabled = false
        
        viewSound.isHidden = !questionType.isMainWordEnglish
        
        guard let questionObject = nextQuestion(question), let questionVC = questionObject.viewController else {
            return
        }
        
        verifyButton.buttonState = .disabledVerification
        verifyButton.isHidden = questionType.saveAnswerWhenGoToNextQuestion
        
        DispatchQueue.main.async {
            self.pageViewController.setViewControllers([questionVC], direction: .forward, animated: true, completion: { [weak self] _ in
                guard let sself = self else {
                    return
                }
                
                sself.tellChildThatViewDidAppearIfNeeded()
            })
        }
    }
    
    func tellChildThatViewDidAppearIfNeeded() {
        if viewWasAppeared {
            currentQuestionVC?.superViewDidAppeared()
        }
    }
    
    func popWithProgressLosing() {
        let alertVC = UIAlertController(title: "warning".localizedWithCurrentLanguage(), message: "progress-lost".localizedWithCurrentLanguage(), preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "close".localizedWithCurrentLanguage(), style: .destructive) { [weak self] _ in
            guard let sself = self else {
                return
            }
            
            AnalyticsHelper.logEventWithParameters(event: sself.isUsedForExam ? .ME_Exam_Outed : .ME_Lesson_Outed, themeId: sself.theme?.name ?? sself.topic?.theme?.name, topicId: sself.topic?.name, typeOfLesson: sself.lessonType, starsCount: nil, language: nil)
            self?.popVC()
        }
        
        let noAction = UIAlertAction(title: "cancel".localizedWithCurrentLanguage(), style: .cancel, handler: nil)
        
        alertVC.addAction(yesAction)
        alertVC.addAction(noAction)
        
        present(alertVC, animated: true, completion: nil)
    }
    
    // MARK: - Result
    
    func showResultScreen(result: Float) {
        if isUsedForExam {
            switch result {
            case 1.0:
                guard let themeName = theme.name else {
                    print("There is no theme name")
                    return
                }
                
                LearningProgressManager.examPassed(themeName: themeName)
                
                let experience = LearningProgressManager.calculateExperience(theme: theme)
                
                pushResultScreen(with: 1, experience: experience)
                
                AnalyticsHelper.logEventWithParameters(event: .ME_Exam_Finished, themeId: theme?.name ?? topic?.theme?.name, topicId: topic?.name, typeOfLesson: lessonType, starsCount: 1, language: nil)
            default:
                AnalyticsHelper.logEventWithParameters(event: .ME_Exam_Finished, themeId: theme?.name ?? topic?.theme?.name, topicId: topic?.name, typeOfLesson: lessonType, starsCount: 0, language: nil)
                lessonFailed()
            }
        } else {
            LearningProgressManager.calculateStarsAndExperience(result, lessonType: lessonType!, topic: topic) { [weak self] stars, experience in
                guard let sself = self else {
                    return
                }
                
                AnalyticsHelper.logEventWithParameters(event: .ME_Lesson_Finished, themeId: sself.theme?.name ?? sself.topic?.theme?.name, topicId: sself.topic?.name, typeOfLesson: sself.lessonType, starsCount: stars, language: nil)
                
                if stars > 0 {
                    sself.pushResultScreen(with: stars, experience: experience)
                } else {
                    sself.lessonFailed()
                }
            }
        }
    }
    
    func pushResultScreen(with stars: Int, experience: Int) {
        let completionVC = VCEnum.levelCompletion.vc as! LevelCompletionVC
        completionVC.setInfo(stars: stars, experience: experience)
        completionVC.topic = topic
        
        completionVC.isExamCompletion = isUsedForExam
        
        navigationController?.pushViewController(completionVC, animated: true)
    }
    
    func lessonFailed() {
        let levelFailedVC = VCEnum.levelFailed.vc as! LevelFailedVC
        
        levelFailedVC.isUsedForExam = isUsedForExam
        levelFailedVC.delegate = self
        
        present(levelFailedVC, animated: true, completion: nil)
    }
    
    // MARK: - LevelFailedDelegate
    
    func backToThemePressed() {
        popToController(with: TopicsViewController.self)
    }
    
    func retryPressed() {
        startLesson()
    }
    
    // MARK: - Actions
    
    @IBAction func close(_ sender: Any) {
        if progressView.progress > 0.0 {
            popWithProgressLosing()
        } else {
            popVC()
        }
    }
    
    @IBAction func verifyPressed(_ sender: LessonActionButton) {
        guard let answer = currentQuestionVC?.selectedWord() else {
            return
        }
        let isCorrectAndCorrectAnswer = questionValidator.checkAnswer(answer)

        if (isCorrectAndCorrectAnswer.isCorrect) {
            AudioManager.shared.playCorrectAnswerSound()
        }
        
        if questionProvider.canSkipQuestion, !isCorrectAndCorrectAnswer.isCorrect {
            lessonActionView.state = .skip
        } else {
            lessonActionView.state = isCorrectAndCorrectAnswer.isCorrect ? .correct : .wrong
            let progress = questionValidator.saveProgress(answer)
            if progress == 1 {
                setFinishState()
            }
        }
        
        currentQuestionVC?.changeState(isCorrect: isCorrectAndCorrectAnswer.isCorrect, correctAnswer: isCorrectAndCorrectAnswer.correctAnswer)
        
        verifyButton.isHidden = true
    }
    
    @IBAction func speakWordPressed(_ sender: Any) {
        guard let word = labelWord.text else {
            return
        }
        speechSynthesizer.speak(word)
        buttonSpeakWord.isUserInteractionEnabled = false
    }
    
    func answerWasSelected(_ selected: Bool) {
        var enabled = selected
        
        if questionType.saveAnswerWhenGoToNextQuestion {
            if let selectedWord = currentQuestionVC?.selectedWord() {
                let isCorrectAndCorrectAnswer = questionValidator.checkAnswer(selectedWord)
                currentQuestionVC?.changeState(isCorrect: isCorrectAndCorrectAnswer.isCorrect, correctAnswer: isCorrectAndCorrectAnswer.correctAnswer)
                
                enabled = isCorrectAndCorrectAnswer.isCorrect
                
                if enabled {
                    lessonActionView.state = .correct
                } else if let attemptsCount = currentQuestionVC?.attemptsCount, attemptsCount > 0 {
                    lessonActionView.enabled = false
                } else if questionProvider.canSkipQuestion {
                    lessonActionView.state = .skip
                } else {
                    lessonActionView.state = .wrong
                }
                
                if lessonActionView.enabled, lessonActionView.state == .correct || lessonActionView.state == .wrong {
                    let progress = questionValidator.saveProgress(selectedWord)
                    if progress == 1 {
                        setFinishState()
                    }
                }
                
            } else {
                enabled = false
            }
        }
        
        if verifyButton.buttonState.isEnabled != enabled {
            verifyButton.buttonState = verifyButton.buttonState.negativeState
        }
    }
    
    // MARK: - Data
    
    func nextQuestion(_ question: Question) -> QuestionProtocol? {
        var questionVC: QuestionProtocol?
        
        switch questionType {
        case .association:
            questionVC = VCEnum.findTheImage.vc as? QuestionProtocol
        case .pronunciation:
            questionVC = VCEnum.pronunciation.vc as? QuestionProtocol
        case .spelling:
            questionVC = VCEnum.spelling.vc as? QuestionProtocol
        case .translation:
            questionVC = VCEnum.translation.vc as? QuestionProtocol
        case .listenType, .lookType:
            questionVC = VCEnum.typeTheWord.vc as? QuestionProtocol
        }
        
        speechSynthesizer.recordSupport = questionType == .pronunciation
        
        questionVC?.selectionHandler = { [weak self] selected in
            guard let sself = self else {
                return
            }
            
            sself.answerWasSelected(selected)
        }
        
        questionVC?.verifyHandler = { [weak self] in
            guard let sself = self else {
                return
            }
            
            sself.verifyPressed(sself.verifyButton)
        }
        
        questionVC?.verifyResultsHandler = { [weak self] in
            guard let sself = self else {
                return
            }
            if sself.lessonActionView.enabled {
                sself.showLessonActionView()
            }
            if sself.lessonActionView.enabled, sself.lessonActionView.state != .skip {
                let progress = sself.questionValidator.getProgress()
                sself.progressView.updateProgress(progress: CGFloat(progress), animated: true, delay: 0.2)
                sself.updateMistakes()
            }
            sself.lessonActionView.enabled = true
        }
        
        questionVC?.startSpeechRecognitionHandler = { [weak self] in
            self?.speechSynthesizer.stopSpeech()
        }
        
        questionVC?.attemptsCount = questionType.attemptsBeforeSkipping
        questionVC?.question = question
        
        currentQuestionVC = questionVC
        
        if isUsedForExam {
            labelLessonTitle.text = questionType.message
        }
        
        return questionVC
    }
    
    // MARK: - TEMP
    
    @IBAction func cheatsPressed(_ sender: Any) {
        let alertVC = UIAlertController(title: "Cheat Menu", message: "Choose amount of stars for this lesson", preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let failed = UIAlertAction(title: "0 star", style: .default) { [weak self] _ in
            guard let sself = self else {
                return
            }
            
            sself.showResultScreen(result: 0.5)
        }
        
        let oneStar = UIAlertAction(title: "1 star", style: .default) { [weak self] _ in
            guard let sself = self else {
                return
            }
            
            sself.showResultScreen(result: 0.7)
        }
        
        let twoStar = UIAlertAction(title: "2 stars", style: .default) { [weak self] _ in
            guard let sself = self else {
                return
            }
            
            sself.showResultScreen(result: 0.8)
        }
        
        let threeStar = UIAlertAction(title: "3 stars (if you want to pass quiz choose this item)", style: .default) { [weak self] _ in
            guard let sself = self else {
                return
            }
            
            sself.showResultScreen(result: 1.0)
        }
        
        alertVC.addAction(cancel)
        alertVC.addAction(failed)
        alertVC.addAction(oneStar)
        alertVC.addAction(twoStar)
        alertVC.addAction(threeStar)
        
        present(alertVC, animated: true, completion: nil)
    }
    
    // MARK: - LessonActionView
    
    func showLessonActionView() {
        showLessonActionConstraint.priority = .defaultHigh
        hideLessonActionConstraint.priority = .defaultLow
        
        UIView.animate(withDuration: 0.35) {
            self.lessonActionViewContainer.superview?.layoutIfNeeded()
        }
    }
    
    func hideLessonActionView(completion: ((Bool) -> ())? = nil) {
        showLessonActionConstraint.priority = .defaultLow
        hideLessonActionConstraint.priority = .defaultHigh
        
        UIView.animate(withDuration: 0.25, animations: {
            self.lessonActionViewContainer.superview?.layoutIfNeeded()
        }, completion: completion)
    }
    
    func setFinishState() {
        switch lessonActionView.state! {
        case .correct:
            lessonActionView.state = .correctFinish
        case .wrong:
            lessonActionView.state = .wrongFinish
        default:
            break
        }
    }
    
    // MARK: - LessonActionViewDelegate
    
    func nextButtonPressed(state: LessonActionView.State) {
        hideLessonActionView { [weak self] _ in
            guard let sSelf = self else {
                return
            }
            switch state {
            case .correct, .wrong, .correctFinish, .wrongFinish:
                let nextQuestionObject = sSelf.questionProvider.nextQuestion()
                sSelf.goToNextScreen(nextQuestionObject: nextQuestionObject)
            case .skip:
                let nextQuestionObject = sSelf.questionProvider.skipAndGetNextQuestion()
                sSelf.goToNextScreen(nextQuestionObject: nextQuestionObject)
            }
        }
    }
    
    // Mistakes count
    
    func updateMistakes() {
        let index = questionValidator.mistakesCounter - 1
        guard heartsStackView.arrangedSubviews.indices.contains(index) else {
            return
        }
        let heart = heartsStackView.arrangedSubviews[index]
        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseInOut, animations: {
            heart.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { finished in
            if finished {
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                    heart.transform = CGAffineTransform(scaleX: 0.15, y: 0.15)
                }, completion: { finished in
                    if finished {
                        heart.alpha = 0
                    }
                })
            }
        }
    }
    
    // MARK: - SpeechSynthesizerDelegate
    
    func speechSynthesizerDidFinish() {
        DispatchQueue.main.async { [weak self] in
            guard let sself = self else {
                return
            }
            
            sself.buttonSpeakWord.isUserInteractionEnabled = sself.questionType.isMainWordEnglish
        }
    }
}
