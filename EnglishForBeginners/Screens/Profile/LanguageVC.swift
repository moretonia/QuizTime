//
//  LanguageVC.swift
//  EnglishForBeginners
//
//  Created by Sergey Aleksandrov on 04/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import iCarousel

class LanguageVC: BaseVC, iCarouselDelegate, iCarouselDataSource {    
    
    @IBOutlet weak var carouselView: iCarousel!    
    @IBOutlet weak var backButton: UIButton!
    
    let languages = NativeLanguage.allLanguages
    
    var cellSize: CGSize {
        return CGSize(width: carouselView.frame.height - 20, height: carouselView.frame.height)
    }
    
    let cellSpacing: CGFloat = 1.07
    
    // MARK: - ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layoutIfNeeded()
        carouselView.reloadData()
        carouselView.type = .custom
        carouselView.scrollSpeed = 0.6
        carouselView.decelerationRate = 0.9
        scrollToUserlanguage()
        backButton.isHidden = UserDefaultsManager.shared.userLanguage == nil
    }

    // MARK: - iCarouselDataSource
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return languages.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var languageView: LanguageView
        if view == nil {
            languageView = LanguageView.or_loadFromNib() 
        } else {
            languageView = view as! LanguageView
        }
        let language = languages[index]
        languageView.imageView.image = language.image
        languageView.titleLabel.text = language.displayName.capitalized
        languageView.frame.size = cellSize
        
        return languageView
    }
    
    func carousel(_ carousel: iCarousel, itemTransformForOffset offset: CGFloat, baseTransform transform: CATransform3D) -> CATransform3D {
        
        let absClampedOffset = min(2, abs(offset))
        let clampedOffset = min(2, max(-2, offset))
        
        // linear function for values: (0 : 1.4, 1 : 1.3, 2 : 1.23)
        let itemZoom = -0.085 * absClampedOffset + 1.40
        // linear function for values: (0 : 1.16, 1 : 1.18, 2 : 1.4)
        let spacing = 0.12 * (absClampedOffset + 1) + 1.0067
        let scaleFactor = 1 + absClampedOffset * (1 / itemZoom - 1)
        let offset = (scaleFactor * offset + scaleFactor * (spacing - 1) * clampedOffset) * carousel.itemWidth * cellSpacing
        var transform = CATransform3DTranslate(transform, offset, 0, -absClampedOffset)
        transform = CATransform3DScale(transform, scaleFactor, scaleFactor, 1)
        
        return transform
    }
    
    func carouselItemWidth(_ carousel: iCarousel) -> CGFloat {
        return cellSize.width
    }
    
    // MARK: - iCarouselDelegate
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch option {
        case .wrap:
            return 1.0
        case .spacing:
            return cellSpacing
        case .fadeMax:
            return 0.0
        case .fadeMin:
            return 0.0
        case .fadeMinAlpha:
            return 0.5
        default:
            return value
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func close() {
        popVC()
    }
    
    @IBAction func ok() {
        if UserDefaultsManager.shared.userLanguage == nil {
            AppRootViewController.shared?.openMainScreen()
        } else {
            popVC()
        }
        UserDefaultsManager.shared.userLanguage = languages[carouselView.currentItemIndex].rawValue
    }
    
    // MARK: -
    
    func scrollToUserlanguage() {
        if let userLanguage = UserDefaultsManager.shared.userLanguage, let language = NativeLanguage(rawValue: userLanguage), let index = languages.firstIndex(of: language) {
            carouselView.scrollToItem(at: index, animated: false)
        } else {
            for preferredLanguage in Locale.preferredLanguages {
                if let index = languages.firstIndex(where: { preferredLanguage.contains($0.identifier) }) {
                    carouselView.scrollToItem(at: index, animated: false)
                    return
                }
            }
        }
    }
}
