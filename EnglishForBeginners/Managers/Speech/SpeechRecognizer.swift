//
//  SpeechRecognizer.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 15/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation
import Speech
import ORCommonCode_Swift

protocol SpeechRecognizerProtocol {
    func startRecognition(withContextualStrings strings: [String])
    func stopRecognition()
    var delegate: SpeechRecognizerDelegate? {get set}
    var isActive: Bool {get}
    var isAvailable: Bool {get}
}

protocol SpeechRecognizerDelegate: class{
    func speechRecognizer(_ speechRecognizer: SpeechRecognizer, didRecognized text: String)
    func speechRecognizerStarted()
}

class SpeechRecognizer: NSObject, SpeechRecognizerProtocol, SFSpeechRecognizerDelegate {
    
    let audioEngine = AVAudioEngine()
    var speechRecognizer: SFSpeechRecognizer?
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    weak var delegate: SpeechRecognizerDelegate?
    
    var isActive: Bool {
        return audioEngine.isRunning
    }
    
    var isAvailable = false
    
    // MARK: - Lifecycle
   
    override init() {
        super.init()
        
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        speechRecognizer?.delegate = self
        isAvailable = speechRecognizer?.isAvailable ?? false        
    }
    
    // MARK: - Permissions
    
    func requestSpeechAuthorization(completion: @escaping () -> ()) {
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized:
            completion()
        case .denied:
            showSpeechDeniedErrorAlert()
        case .restricted:
            showSpeechRestrictedErrorAlert()
        case .notDetermined:
            SFSpeechRecognizer.requestAuthorization { (authStatus) in
                if authStatus == .authorized {
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
        @unknown default:
            completion()
        }
    }
    
    func requestMicrophonePermission(completion: @escaping () ->()) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            completion()
        case .denied:
            showMicrophoneUsageErrorAlert()
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if granted {
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
        @unknown default:
            completion()
        }
    }
    
    func requestPermissions(completion: @escaping () ->()) {
        requestSpeechAuthorization { [weak self] in
            self?.requestMicrophonePermission {
                completion()
            }
        }
    }
    
    func recordAndRecognizeSpeech(withContextualStrings strings: [String]) {
        
        setPlayAndRecordMode()
        
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.request.append(buffer)
            self.request.contextualStrings = strings
            self.request.shouldReportPartialResults = true
            self.request.taskHint = .dictation
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            return print(error)
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { [weak self] (result, error) in
            if let result = result {
                DispatchQueue.main.async {
                    guard let sself = self else {
                        return
                    }
                    sself.delegate?.speechRecognizer(sself, didRecognized: result.bestTranscription.formattedString)
                }
            }
        })
    }
    
    func setPlayAndRecordMode() {
        let audioSession = AVAudioSession.sharedInstance()
        
        if audioSession.category == AVAudioSession.Category.playAndRecord && audioSession.mode == AVAudioSession.Mode.measurement {
            return
        }
        
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .measurement)
        } catch {
            print(error)
        }
    }
    
    func startRecognition(withContextualStrings strings: [String] = []) {
        requestPermissions {[weak self] in
            self?.delegate?.speechRecognizerStarted()
            DispatchQueue.global().async { [weak self] in
                self?.recordAndRecognizeSpeech(withContextualStrings: strings)
            }
        }
    }
    
    func stopRecognition() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        request.endAudio()
        recognitionTask?.cancel()
    }
    
    // MARK: - SFSpeechRecognizerDelegate
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        isAvailable = available
    }
    
    // MARK: - Alerts
    
    func showSpeechDeniedErrorAlert() {
        let message = "speech-usage-cancel".localizedWithCurrentLanguage()
        ErrorPopupHelper.showAlertWithSettings(message: message)
    }
    
    func showSpeechRestrictedErrorAlert() {
        let message = "not-support-speech-recognition".localizedWithCurrentLanguage()
        ErrorPopupHelper.showAlertWithSettings(message: message)
    }
    
    func showMicrophoneUsageErrorAlert() {
        let message = "micro-usage-cancel".localizedWithCurrentLanguage()
        ErrorPopupHelper.showAlertWithSettings(message: message)
    }
}
