//
//  TranslationVC.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 19/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

class TranslationVC: BaseLevelVC, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func selectedWord() -> String {
        guard let selectedIndex = tableView.indexPathForSelectedRow?.row, let word = question.answers?[selectedIndex].word else {
            fatalError("Word wasn't selected")
        }
        view.isUserInteractionEnabled = false
        return word
    }
    
    override func changeState(isCorrect: Bool, correctAnswer: Answer?) {
        let selectedIndicator = getSelectedValidityIndicator()
        let correctIndicator = getCorrectValidityIndicator(isCorrect: isCorrect, correctAnswer: correctAnswer)
        animateVerifying(isCorrect: isCorrect, indicator: selectedIndicator, correctIndicator: correctIndicator)
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return question.answers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TranslationTVCell.self), for: indexPath) as! TranslationTVCell
        cell.labelWord.text = question.answers?[indexPath.row].translation ?? question.answers?[indexPath.row].word
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectionHandler(true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let minBottomSpace: CGFloat = 50
        let defaultCellHeight: CGFloat = 66
        let compactCellHeight: CGFloat = 57
        let numberOfItems = question.answers?.count ?? 0
        let bottomSpace = tableView.frame.height - defaultCellHeight * CGFloat(numberOfItems)
        
        return bottomSpace > minBottomSpace ? defaultCellHeight : compactCellHeight
    }
    
    // MARK: - BaseLevelVC methods
    
    override func getSelectedValidityIndicator() -> ValidityIndicatorView? {
        guard let selectedIndex = tableView.indexPathForSelectedRow,
            let selectedCell = tableView.cellForRow(at: selectedIndex) as? TranslationTVCell,
            let selectedIndicator = selectedCell.viewCorrect else {
                return nil
        }
        return selectedIndicator
    }
    
    override func getCorrectValidityIndicator(isCorrect: Bool, correctAnswer: Answer?) -> ValidityIndicatorView? {
        guard !isCorrect, let correctAnswer = correctAnswer,
            let index = question.answers?.firstIndex(of: correctAnswer),
            let correctCell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? TranslationTVCell else {
                return nil
        }
        return correctCell.viewCorrect
    }
}
