//
//  BaseNavigationController.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 14/03/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return visibleViewController?.preferredStatusBarStyle ?? .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
