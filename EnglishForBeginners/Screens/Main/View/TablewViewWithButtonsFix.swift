//
//  TablewViewWithButtonsFix.swift
//  EnglishForBeginners
//
//  Created by Sergey Aleksandrov on 03/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit

class TablewViewWithButtonsFix: UITableView {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        delaysContentTouches = false        
        for case let scrollView as UIScrollView in subviews {
            scrollView.delaysContentTouches = false
        }
    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }

}
