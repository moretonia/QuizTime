//
//  ErrorPopupHelper.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 11/04/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import Foundation
import UIKit
import ORCommonUI_Swift

class ErrorPopupHelper {
    static func showError(_ error: NSError, title: String, parentVC: UIViewController) {
        if let error = error.userInfo["NSUnderlyingError"] as? Error {
            parentVC.or_showAlert(title: title, message: error.localizedDescription)
        }
    }
    
    static func showAlertWithSettings(message: String) {
        let alertVC = UIAlertController(title: "error".localizedWithCurrentLanguage(), message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "cancel".localizedWithCurrentLanguage(), style: .default, handler: nil))
        alertVC.addAction(UIAlertAction(title: "settings".localizedWithCurrentLanguage(), style: .default, handler: { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }))
        let parentVC = UIApplication.shared.windows.first?.rootViewController
        parentVC?.present(alertVC, animated: true, completion: nil)
    }
}

