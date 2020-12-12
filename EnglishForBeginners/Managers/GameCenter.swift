//
//  GameCenter.swift
//  EnglishForBeginners
//
//  Created by Nikita Egoshin on 4/9/18.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit
import GameKit

extension GameCenter {    
    
    struct ScoreRecord {
        var playerName: String
        var value: Int64
    }
}

class GameCenter: NSObject, GKGameCenterControllerDelegate {
    
    static private(set) var shared: GameCenter = GameCenter()
    
    private let kScoreLeaderboardID = "com.brolandsen.EnglishForBeginners.main_leaderboard"
    private let requestDelay: TimeInterval = 2
    private let initialRequestAttemts = 15
    private var requestAttemts = 0
    
    var isEnabled = true {
        didSet {
            if oldValue && !isEnabled && initiateByUser {
                showAuthErrorAlert()
            }
        }
    }
    
    var initiateByUser = false
    
    var isAuthenticated: Bool {
        return GKLocalPlayer.local.isAuthenticated
    }    
    
    // MARK: - Auth

    func authenticate(_ alreadyAuthenticatedHandler: (() -> Void)? = nil, completion: @escaping (Bool, Error?) -> ()) {
        let player = GKLocalPlayer.local
        
        player.authenticateHandler = { [weak self] vc, error in
            guard let sself = self else {
                return
            }
            
            if let authVC = vc, let parentVC = UIApplication.shared.windows.first?.rootViewController {
                if sself.initiateByUser {
                    parentVC.present(authVC, animated: true, completion: nil)
                }
                completion(true, nil)
            } else if sself.isAuthenticated {
                sself.isEnabled = true
                if sself.initiateByUser {
                    alreadyAuthenticatedHandler?()
                }
            } else {
                sself.isEnabled = false
                completion(false, nil)
            }
            
            sself.initiateByUser = false
        }
    }
    
    // MARK: - Score load

    fileprivate func checkScore(submittedScore: Int64, completion: @escaping (Bool, Error?) -> ()) {
        
        let leaderboard = GKLeaderboard(players: [GKLocalPlayer.local])
        leaderboard.identifier = kScoreLeaderboardID
        
        leaderboard.loadScores { [weak self] (scores, error) in
            
            guard let sself = self else {
                completion(false, nil)
                return
            }
            
            guard error == nil else {
                completion(false, error)
                return
            }
            
            guard let scores = scores else {
                sself.checkScoreWithDelay(submittedScore: submittedScore, completion: completion)
                return
            }
            
            let records = GameCenter.scoreRecords(from: scores)
            if let score = records.first, score >= submittedScore {
                completion(true, nil)
            } else {
                sself.checkScoreWithDelay(submittedScore: submittedScore, completion: completion)
            }
        }
    }
    
    fileprivate func checkScoreWithDelay(submittedScore: Int64, completion: @escaping (Bool, Error?) -> ()) {
        if requestAttemts > 0 {
            requestAttemts -= 1
            DispatchQueue.main.asyncAfter(deadline: .now() + requestDelay) { [weak self] in
                self?.checkScore(submittedScore: submittedScore, completion: completion)
            }
        } else {
            let error = AppError.errorWithCode(.requestTimedOut, customDescription: "timeout".localizedWithCurrentLanguage())
            completion(false, error)
        }
    }
    
    func showLeaderboard(score: Int64, from parentVC: UIViewController, completion: @escaping (Bool, Error?) -> ()) {
        guard isEnabled else {
            showAuthErrorAlert()
            completion(false, nil)
            return
        }
        initiateByUser = true
        guard isAuthenticated else {
            authenticate({ [weak self] in
                self?.showLeaderboard(score: score, from: parentVC, completion: completion)
            }, completion: completion)
            return
        }        
        submitScores([score]) { [weak self] error in
            guard let sself = self else {
                completion(false, error)
                return
            }
            
            guard error == nil else {
                completion(false, error)
                return
            }
            
            sself.requestAttemts = sself.initialRequestAttemts
            sself.checkScoreWithDelay(submittedScore: score) { [weak self] success, error in
                guard let sself = self else {
                    completion(false, error)
                    return
                }
                
                guard error == nil else {
                    completion(false, error)
                    return
                }
                
                if success {
                    sself.openLeaderboard(from: parentVC)
                }
                
                completion(success, nil)
            }
        }
    }
    
    fileprivate func openLeaderboard(from parentVC: UIViewController) {
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = .leaderboards
        gcVC.leaderboardIdentifier = kScoreLeaderboardID
        parentVC.present(gcVC, animated: true, completion: nil)
    }
    
    // MARK: - Score submit
    
    fileprivate func createScore(withValue val: Int64) -> GKScore {
        let score = GKScore(leaderboardIdentifier: kScoreLeaderboardID)
        score.value = val
        
        return score
    }

    func submitScores(_ scores: [Int64], completion: @escaping (Error?) -> Void) {
        
        var scoreList: [GKScore] = []
        
        for val in scores {
            let record = createScore(withValue: val)
            scoreList.append(record)
        }
        
        GKScore.report(scoreList, withCompletionHandler: completion)
    }
    
    // MARK: - Prepare Data
    
    static fileprivate func scoreRecords(from scores: [GKScore]) -> [Int64] {
        var scoreVals: [Int64] = []
        
        for item in scores {
            let playerName = item.player.displayName
            let record = ScoreRecord(playerName: playerName, value: item.value)
            
            scoreVals.append(record.value)
        }
        
        return scoreVals
    }
    
    // MARK: - GKGameCenterControllerDelegate
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Alerts
    
    func showAuthErrorAlert() {
        let message = "already-cancel-auth".localizedWithCurrentLanguage()
        ErrorPopupHelper.showAlertWithSettings(message: message)
    }
}
