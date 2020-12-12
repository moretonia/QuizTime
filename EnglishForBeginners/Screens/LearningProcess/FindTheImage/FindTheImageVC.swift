//
//  FindTheImageVC.swift
//  EnglishForBeginners
//
//  Created by Sergey Aleksandrov on 19/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit
import PureLayout

class FindTheImageVC: BaseLevelVC, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let itemSpacing: CGFloat = 2
    let numberOfItemsPerRow = 2
    
    var selectedIndexPath: IndexPath?

    // MARK: - BaseLevelVC
    
    override func selectedWord() -> String {
        guard let selectedIndex = collectionView.indexPathsForSelectedItems?.first?.row, let selectedWord = question.answers?[selectedIndex].word else {
            fatalError("")
        }
        return selectedWord
    }
    
    override func changeState(isCorrect: Bool, correctAnswer: Answer?) {
        collectionView.isUserInteractionEnabled = false
        let selectedIndicator = getSelectedValidityIndicator()
        let correctIndicator = getCorrectValidityIndicator(isCorrect: isCorrect, correctAnswer: correctAnswer)
        animateVerifying(isCorrect: isCorrect, indicator: selectedIndicator, correctIndicator: correctIndicator)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return question.answers?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: FindTheImageCVCell.self), for: indexPath) as! FindTheImageCVCell
        if let imageName = question.answers?[indexPath.row].imageName {
            cell.imageView.image = UIImage(named: imageName)
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalHorizontalSpacing = (CGFloat(numberOfItemsPerRow) - 1) * itemSpacing
        let width = (collectionView.frame.width - totalHorizontalSpacing) / CGFloat(numberOfItemsPerRow)
        
        let numberOfItemsPerColumn = (question.answers?.count ?? 0) / numberOfItemsPerRow
        let totalVerticalSpacing = (CGFloat(numberOfItemsPerColumn) - 1) * itemSpacing
        let height = (collectionView.frame.height - totalVerticalSpacing) / CGFloat(numberOfItemsPerColumn)
        
        return CGSize(width: width, height: height)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath == selectedIndexPath {
            deselectItem()
        } else {
            selectItem(at: indexPath)
        }
    }
    
    // MARK: - Selection
    
    func selectItem(at indexPath: IndexPath) {
        for index in 0..<collectionView.numberOfItems(inSection: 0) {
            let cellIndexPath = IndexPath(item: index, section: 0)
            let cell = collectionView.cellForItem(at: cellIndexPath) as! FindTheImageCVCell
            if index == indexPath.row {
                cell.animateEnabling()
            } else {
                cell.animateDisabling()
            }
        }
        selectionHandler(true)
        selectedIndexPath = indexPath
    }
    
    func deselectItem() {
        guard let selectedIndexPath = selectedIndexPath else {
            return
        }
        for index in 0..<collectionView.numberOfItems(inSection: 0) where index != selectedIndexPath.row {
            let indexPath = IndexPath(item: index, section: 0)
            let cell = collectionView.cellForItem(at: indexPath) as! FindTheImageCVCell
            cell.animateEnabling()
        }
        selectionHandler(false)
        self.selectedIndexPath = nil
    }
    
    // MARK: - BaseLevelVC methods
    
    override func getSelectedValidityIndicator() -> ValidityIndicatorView? {
        guard let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first,
            let selectedCell = collectionView.cellForItem(at: selectedIndexPath) as? FindTheImageCVCell else {
                return nil
        }
        return selectedCell.validityIndicatorView
    }
    
    override func getCorrectValidityIndicator(isCorrect: Bool, correctAnswer: Answer?) -> ValidityIndicatorView? {
        guard !isCorrect, let correctAnswer = correctAnswer,
            let correctIndex = question.answers?.firstIndex(of: correctAnswer),
            let correctCell = collectionView.cellForItem(at: IndexPath(item: correctIndex, section: 0)) as? FindTheImageCVCell else {
                return nil
        }
        return correctCell.validityIndicatorView
    }
}
