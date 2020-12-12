//
//  SpeechSynthesizer.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 07/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation
import AVFoundation

protocol SpeechSynthesizerDelegate: class {
    func speechSynthesizerDidFinish()
}

class SpeechSynthesizer: NSObject, AVSpeechSynthesizerDelegate {
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    var recordSupport = false
    
    weak var delegate: SpeechSynthesizerDelegate?
    
    override init() {
        super.init()
        
        speechSynthesizer.delegate = self
    }
    
    private func speechUtterance(_ text: String) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: text)
        
        utterance.rate = 0.41
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        return utterance
    }
    
    func speak(_ text: String) {
        DispatchQueue.global().async { [weak self] in
            guard let sself = self else {
                return
            }
            if sself.speechSynthesizer.isSpeaking {
                sself.stopSpeech()
            }
            sself.setPlaybackMode()
            let speechUtterance = sself.speechUtterance(text)
            let voice = AVSpeechSynthesisVoice(language: "en-US")
            speechUtterance.voice = voice
            sself.speechSynthesizer.speak(speechUtterance)
        }
    }
    
    func stopSpeech(_ force: Bool = true) {
        speechSynthesizer.stopSpeaking(at: force ? .immediate : .word)
    }
    
    func setPlaybackMode() {
        let audioSession = AVAudioSession.sharedInstance()
        if audioSession.category == .playback && audioSession.mode == .default {
            return
        }
        
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback, mode: .default)
        } catch {
            print(error)
        }
    }
    
    func setRecordModeIfNeed() {
        guard recordSupport else {
            delegate?.speechSynthesizerDidFinish()
            return
        }
        DispatchQueue.global().async { [weak self] in
            guard let sself = self else {
                return
            }
            sself.setRecordMode()
            sself.delegate?.speechSynthesizerDidFinish()
        }        
    }
    
    func setRecordMode() {
        let audioSession = AVAudioSession.sharedInstance()
        if audioSession.category == AVAudioSession.Category.playAndRecord && audioSession.mode == AVAudioSession.Mode.measurement {
            return
        }
        do {
            try audioSession.setCategory(AVAudioSession.Category(rawValue: AVAudioSession.Category.playAndRecord.rawValue), mode: .measurement)
        } catch {
            print(error)
        }
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        setRecordModeIfNeed()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        setRecordModeIfNeed()        
    }
}
