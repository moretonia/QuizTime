//
//  AudioManager.swift
//  EnglishForBeginners
//
//  Created by Roman Petrov on 04.08.2020.
//  Copyright © 2020 Omega-R. All rights reserved.
//

import Foundation
import AVFoundation

class AudioManager {
    static let shared = AudioManager()

    var audioPlayer: AVAudioPlayer?

    init() {
        queue.shuffle()
    }

    private var rnd = SystemRandomNumberGenerator()

    private var queue = [
        "aha",
        "all_right",
        "correct",
        "excelent",
        "good",
        "nicely_done",
        "ok",
        "thats_right",
        "well_done",
        "yes",
        "you_got_it",
        "you_re_right",
    ]

    func playCorrectAnswerSound() {
        playSound(queue[0])
        let file = queue.remove(at: 0)
        let middleIdx = queue.count / 2
        let range = queue.count - middleIdx
        queue.insert(file, at: middleIdx - 1 + Int(truncatingIfNeeded: (rnd.next() % UInt(range))))
    }

    func playQuizResultSound(stars: Int) {
        if (stars == 1) {
            playSound("one_star")
        } else if (stars == 2) {
            playSound("two_stars")
        } else if (stars == 3) {
            playSound("three_stars")
        }
    }

    private func playSound(_ file: String) {
        let filePath = Bundle.main.path(forResource: file, ofType: "mp3")
        let soundURL = URL(fileURLWithPath: filePath!)
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: soundURL)
        } catch {
            print("Player not available")
        }

        audioPlayer?.setVolume(1.0, fadeDuration: 0)
        audioPlayer?.play()
    }
}
