//
//  DictionaryVC.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 07/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

class DictionaryVC: BaseVC, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var itemsIds = [String]()
    var themeName: String!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var words = [VocabularyItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        VocabularyManager.vocabularyItems(with: itemsIds, themeName: themeName) { [weak self] (words) in
            guard let words = words else {
                return
            }
            self?.words = words
            self?.collectionView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Temp: Remove if navigation bar will return
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dictionaryItem = segue.destination as? DictionaryDetailVC, let selectedCell = sender as? UICollectionViewCell, let index = collectionView.indexPath(for: selectedCell)?.row {
            dictionaryItem.words = words
            dictionaryItem.selectedIndex = index
        }
    }
    
    // MARK: - Actions
    
    @IBAction func close(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: DictionaryCVCell.self), for: indexPath) as! DictionaryCVCell
        cell.itemName.text = words[indexPath.row].word
        
        if let imageName = words[indexPath.row].imageName {
            cell.imageView.image = UIImage(named: imageName)
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Two cells in a row with 2 points space between them
        let cellWidth = collectionView.frame.width / 2 - 1
        let cellHeight = cellWidth * 0.76
        
        let cellSize = CGSize(width: cellWidth, height: cellHeight)
        
        return cellSize
    }
}
