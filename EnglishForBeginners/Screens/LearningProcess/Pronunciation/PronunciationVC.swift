//
//  PronunciationVC.swift
//  EnglishForBeginners
//
//  Created by Sergey Aleksandrov on 19/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit
import ORCommonUI_Swift

class PronunciationVC: BaseLevelVC, SpeechRecognizerDelegate {
    
    
    @IBOutlet weak var imageViewRecord: UIImageView!
    @IBOutlet weak var recordButton: ORCustomContentButton!
    @IBOutlet weak var validityIndicatorView: ValidityIndicatorView!    
    @IBOutlet weak var tryAgainView: UIView!
    
    var firstWaveLayer: CAShapeLayer!
    var secondWaveLayer: CAShapeLayer!
    
    var speechRecognizer: SpeechRecognizerProtocol!
    var recognizedText = "" {
        didSet {
            recognizedLabel.text = recognizedText
            attemptsCount -= 1
            selectionHandler(true)
        }
    }
    
    weak var speechWatingTimer: Timer?
    weak var talkFinishTimer: Timer?
    
    @IBOutlet weak var waveAnimationView: WaveAnimationView!
    
    @IBOutlet weak var recognizedLabel: UILabel!
    
    var recognizedTexts = [String]()
    
    // MARK: - ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changeRecordButtonView(isSelected: false)
        
        speechRecognizer = SpeechRecognizer()
        speechRecognizer.delegate = self
    }
    
    @IBAction func recordButtonTouched(_ sender: ORCustomContentButton) {
        guard speechRecognizer.isAvailable else {
            or_showAlert(title: "speech-recognition-unavailable".localizedWithCurrentLanguage(), message: "device-settings-for-speech".localizedWithCurrentLanguage() + "\n" + "check-internet-for-speech".localizedWithCurrentLanguage())
            return
        }
        if !speechRecognizer.isActive {
            var contextualStrings = [String]()
            if let contextualString = question.answers?.first?.word {
                contextualStrings.append(contextualString)
            }
            speechRecognizer.startRecognition(withContextualStrings: contextualStrings)
            startSpeechRecognitionHandler()
        }
    }
    
    func changeRecordButtonView(isSelected: Bool) {
        recordButton.backgroundColor = isSelected ? AppColors.selectedCellColor : AppColors.notSelectedCellColor
        imageViewRecord.tintColor = isSelected ? AppColors.enabledMicroImage : AppColors.disabledMicroImage
    }
    
    func setRecordButtonFinishedState() {
        recordButton.backgroundColor = AppColors.notSelectedCellColor
        imageViewRecord.tintColor = AppColors.enabledMicroImage
    }
    
    // MARK: - BaseLevelVC
    
    override func selectedWord() -> String {
        return recognizedText
    }
    
    override func changeState(isCorrect: Bool, correctAnswer: Answer?) {
        animateVerifying(isCorrect: isCorrect, indicator: validityIndicatorView)
        recordButton.isEnabled = !isCorrect
        if isCorrect {
            setRecordButtonFinishedState()
        } else {
            checkAttempts()
        }
        stopSpeechWatingTimer()
        stopTalkFinishTimer()
        stopRecognition()
    }
    
    // MARK: - SpeechRecognizerDelegate
    
    func speechRecognizer(_ speechRecognizer: SpeechRecognizer, didRecognized text: String) {
        recognizedTexts.append(text)
        startTalkFinishTimer()
    }
    
    func speechRecognizerStarted() {
        DispatchQueue.main.async { [weak self] in
            self?.recognitionStarted()
        }
    }
    
    // MARK: -
    
    func recognitionStarted() {
        recordButton.isEnabled = false
        changeRecordButtonView(isSelected: true)
        validityIndicatorView.changeState(.disabled)
        recognizedLabel.text = ""
        recognizedTexts = []
        startSpeechWatingTimer()
        waveAnimationView.startAnimation()
        tryAgainView.isHidden = true
    }
    
    func stopRecognition() {
        if speechRecognizer.isActive {
            speechRecognizer.stopRecognition()
        }
        waveAnimationView.stopAnimation()
    }
    
    func checkAttempts() {
        if attemptsCount == 0 {
            recordButton.isEnabled = false
            setRecordButtonFinishedState()
        } else {
            tryAgainView.isHidden = false
            changeRecordButtonView(isSelected: false)
        }
    }
    
    // MARK: - Recognition results handling
    
    func verifyRecognitionResults() {
        guard let correctAnswer = question.answers?.first?.word else {
            return
        }

        if WordCompareHelper.isContains(correctAnswer, in: recognizedTexts) || WordCompareHelper.isContainsFuzzyEqual(correctAnswer, in: recognizedTexts) {
            recognizedText = correctAnswer
        } else if let text = recognizedTexts.last {
            recognizedText = text.firstUppercased
        } else {
            recognizedText = ""
        }
    }
    
    // MARK: - Timers
    
    func startSpeechWatingTimer() {
        if speechWatingTimer == nil {
            speechWatingTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { [weak self] _ in
                guard let sself = self else {
                    return
                }
                sself.attemptsCount -= 1
                sself.selectionHandler(true)
            })
        }
    }
    
    func stopSpeechWatingTimer() {
        speechWatingTimer?.invalidate()
        speechWatingTimer = nil
    }
    
    func startTalkFinishTimer() {
        if talkFinishTimer == nil {
            talkFinishTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { [weak self] _ in
                self?.verifyRecognitionResults()
            })
        }
    }
    
    func stopTalkFinishTimer() {
        talkFinishTimer?.invalidate()
        talkFinishTimer = nil
    }
}
