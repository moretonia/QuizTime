//
//  BaseVC.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 06/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit
import AdColony

class BaseVC: UIViewController {

    let kTagActivityIndicator = 777

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showActivityIndicator() {
        let backgroundView = UIView()
        backgroundView.frame = view.frame
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        backgroundView.isUserInteractionEnabled = true
        backgroundView.tag = kTagActivityIndicator
        
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.color = UIColor.lightGray
        activityIndicator.center = backgroundView.center
        activityIndicator.startAnimating()
        backgroundView.addSubview(activityIndicator)
        
        view.addSubview(backgroundView)
    }
    
    func hideActivityIndicator() {
        DispatchQueue.main.async {
            guard let indicatorView = self.view.viewWithTag(self.kTagActivityIndicator) else {
                return
            }
            
            indicatorView.removeFromSuperview()
        }
    }
    
    func popVC(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }
    
    func popToController(with className: AnyClass) {
        guard let controllers = navigationController?.viewControllers else {
            return
        }

        for controller in controllers {
            if controller.isKind(of: className) {
                navigationController?.popToViewController(controller, animated: true)
            }
        }
    }
    // TODO: Remove when real iAP will be added
    
    func buySelectedTheme(_ theme: Theme, completion: @escaping () -> ()) {
        let alertVC = UIAlertController(title: "Buy theme", message: "Do you want to buy selected theme?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { [weak self] (_) in
            self?.navigationController?.setNeedsStatusBarAppearanceUpdate()
            ThemeManager.buyThemes([theme.name!], completion: {
                completion()
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] (_) in
            self?.navigationController?.setNeedsStatusBarAppearanceUpdate()
        })
        
        alertVC.addAction(yesAction)
        alertVC.addAction(cancelAction)
        
        present(alertVC, animated: true, completion: nil)
    }
    
    func addCustomBackButton() {
        let item = UIBarButtonItem(image: UIImage(named:"icon-back"), style: .plain, target: self, action: #selector(backButtonPressed))
        item.tintColor = UIColor(62, 181, 241)
        navigationItem.leftBarButtonItem = item
        
        navigationController?.navigationBar.or_setExclusiveTouchForViewAndSubviews()
    }
    
    @objc func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
}
