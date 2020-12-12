//
//  LevelFailedVC.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 30/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit
import ORCommonUI_Swift

protocol LevelFailedDelegate: class {
    func backToThemePressed()
    func retryPressed()
}

class LevelFailedVC: BaseVC {

    @IBOutlet weak var labelTitle: UILabel!
    
    var isUsedForExam: Bool = false
    
    weak var delegate: LevelFailedDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        if isUsedForExam {
            labelTitle.text = "quiz-fail".localizedWithCurrentLanguage()
        } else {
            labelTitle.text = "not-pass-level".localizedWithCurrentLanguage()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    
    @IBAction func backToThemePressed(_ sender: Any) {
        AdManager.shared.showInterstitial(in: self) { [weak self] in
            if let sSelf = self {
                sSelf.dismiss(animated: true) {
                    sSelf.delegate?.backToThemePressed()
                }
            }
        }
    }
    
    @IBAction func retryPressed(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.retryPressed()
        }
    }
}
