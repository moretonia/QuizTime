//
//  AppRootViewController.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 26/02/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit
import ORCommonUI_Swift

class AppRootViewController: UIViewController {
    
    static weak var shared: AppRootViewController?
    
    @IBOutlet weak var viewMainContainer: UIView!
    
    weak var contentViewController: UIViewController?

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return contentViewController?.preferredStatusBarStyle ?? .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AppRootViewController.shared = self
        
        showSuitableViewControllerForCurrentApplicationState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: -
    
    fileprivate func showSuitableViewControllerForCurrentApplicationState() {
        if UserDefaultsManager.shared.userLanguage == nil {
            openLanguageScreen()
        } else {
            openMainScreen()
        }
    }
    
    func openMainScreen() {
        let vc = VCEnum.main.vc
        setCurrentContentViewController(vc)
    }
    
    func openLanguageScreen() {
        let vc = VCEnum.language.vc
        setCurrentContentViewController(vc)
    }
    
    func setCurrentContentViewController(_ vc: UIViewController) {
        if let cvc = contentViewController {
            cvc.or_removeFromParentViewController()
        }
        contentViewController = vc
        or_addChildViewController(vc, intoView: viewMainContainer)
    }
}

