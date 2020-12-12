//
//  AdManager.swift
//  EnglishForBeginners
//
//  Created by Roman Petrov on 02.08.2020.
//  Copyright © 2020 Omega-R. All rights reserved.
//

import Foundation
import AdColony

class AdManager: NSObject, AdColonyInterstitialDelegate {
    static let shared = AdManager()

    weak var interstitial:AdColonyInterstitial?
    var onCloseCallback: (() -> ())?

    func initAds() {
        AdColony.configure(withAppID: "app6c278a211b3f420d9d", zoneIDs: [
            "vzcb9bd7ca35b54d959e",
        ], options: nil) { (zones) in
            // configured
            print("AdColony configured")
        }
    }

    func requestInterstitial() {
        AdColony.requestInterstitial(inZone: "vzcb9bd7ca35b54d959e", options: nil, andDelegate: self)
    }

    func showInterstitial(in vc: UIViewController, onClose: (() -> ())?) {
        if let interstitial = self.interstitial, !interstitial.expired {
            onCloseCallback = onClose
            interstitial.show(withPresenting: vc)
        }
    }

    // MARK:- AdColony Interstitial Delegate

    // Store a reference to the returned interstitial object
    func adColonyInterstitialDidLoad(_ interstitial: AdColonyInterstitial) {
        self.interstitial = interstitial
    }

    // Handle loading error
    func adColonyInterstitialDidFail(toLoad error: AdColonyAdRequestError) {
        print("Interstitial request failed with error: \(error.localizedDescription) and suggestion: \(error.localizedRecoverySuggestion!)")
    }

    // Handle expiring ads (optional)
    func adColonyInterstitialExpired(_ interstitial: AdColonyInterstitial) {
        // remove reference to stored ad
        self.interstitial = nil

        // you can request new ad
        self.requestInterstitial()
    }

    // Ad closing callback
    func adColonyInterstitialDidClose(_ interstitial: AdColonyInterstitial) {
        if let callback = onCloseCallback {
            callback()
        }
        onCloseCallback = nil
    }
}
