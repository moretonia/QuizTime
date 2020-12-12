//
//  FBSharer.swift
//  EnglishForBeginners
//
//  Created by Nikita Egoshin on 4/6/18.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit


protocol FBSharerDelegate : class {
    func fbSharerDidFailToLogin(_ sharer: FBSharer, withError error: Error)
    func fbSharerDidFailedToShare(sharer: FBSharer, withError error: Error)
    func userDidCancelSharingToFb(for sharer: FBSharer)
    func fbSharerDidShareContent(_ sharer: FBSharer)
}

class FBSharer : NSObject, SharingDelegate {
    
    fileprivate static let kPublishPermissions = ["publish_actions"]
    
    fileprivate static var loginManager = LoginManager()
    
    fileprivate var delegate: FBSharerDelegate?
    
    
    // MARK: - Sharing
    
    func shareAppInfo(fromVC vc: UIViewController, withDelegate delegate: FBSharerDelegate? = nil) {
        
        prepareToShare(fromVC: vc) {
            let content = ShareLinkContent()
            content.contentURL = URL(string: "https://itunes.apple.com/gb/app/learn-model-english/id1367918761?mt=8")!
  //changed ru to gb 21/7/19
            self.delegate = delegate
            ShareDialog(fromViewController: vc, content: content, delegate: self).show()
        }
    }
    
    func shareUserResults(fromVC vc: UIViewController, link: URL!, quote: String, withDelegate delegate: FBSharerDelegate? = nil) {
        prepareToShare(fromVC: vc) {
//            let photo = FBSDKSharePhoto(image: screenshot, userGenerated: true)!
            let content = ShareLinkContent()
//            content.photos = [photo]
    
            content.contentURL = link
            content.quote = quote
            
            self.delegate = delegate
            ShareDialog(fromViewController: vc, content: content, delegate: self).show()
        }
    }
    
    /*func shareOpenGraph(withObjProps props: [String : Any], objKey: String, action: String, vc: UIViewController) {
        prepareToShare(fromVC: vc) {
            let ogObject = ShareOpenGraphObject(properties: props)
            
            let ogAction = ShareOpenGraphAction(type: action, object: ogObject, key: objKey)
            
            let content = ShareOpenGraphContent()
            content.action = ogAction
            content.previewPropertyName = objKey

            let dialog = ShareDialog()

            dialog.fromViewController = vc
            dialog.shareContent = content
            dialog.mode = .automatic
            
            dialog.show()
        }
    }*/
    
    
    // MARK: - Settings check
    
    func isPublishPermissionsInList(_ permissions: Set<AnyHashable>) -> Bool {
        for permission in FBSharer.kPublishPermissions {
            if !permissions.contains(permission) {
                return false
            }
        }
        
        return true
    }
    
    
    // MARK: - Authentication
    
    fileprivate func prepareToShare(fromVC vc: UIViewController, withCompletion completion: @escaping (() -> Void)) {
        completion()
    }
    
    func login(fromVC vc: UIViewController, completion: @escaping (LoginManagerLoginResult?, Error?) -> Void) {
        FBSharer.loginManager.logIn(permissions: FBSharer.kPublishPermissions, from: vc) { [weak self] (loginResults, error) in
            guard error == nil else {
                if let strongSelf = self {
                    strongSelf.delegate?.fbSharerDidFailToLogin(strongSelf, withError: error!)
                }
                
                return
            }
            
            completion(loginResults, error)
        }
    }
    

    // MARK: - FBSDKSharingDelegate


    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        print("Shared with result \(results)")
    }
    
    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        print("Sharing failed with error: \(error.localizedDescription)")
    }
    
    func sharerDidCancel(_ sharer: Sharing) {
        print("Sharing canceled")
    }
}
