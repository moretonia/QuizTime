//
//  AppDelegate.swift
//  EnglishForBeginners
//
//  Created by Dmitriy Mamatov on 26/02/2018.
//  Copyright © 2018 Omega-R. All rights reserved.
//

import UIKit
import MagicalRecord
import Fabric
import Crashlytics
import FBSDKCoreKit
import Flurry_iOS_SDK
import AdColony

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        KochavaTracker.shared.configure(withParametersDictionary:[kKVAParamAppGUIDStringKey: "ko1k-english-learn-1000-words-elgtgas"], delegate: nil)
         //https://support.freeappanalytics/.com/sdk-integration/ios-sdk-integration//
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        MagicalRecord.setupCoreDataStack(withAutoMigratingSqliteStoreNamed: "EnglishForBeginners")
        
        Crashlytics().debugMode = true
        Fabric.with([Crashlytics.self])
        
        FlurryMessaging.setAutoIntegrationForMessaging()
        let builder = FlurrySessionBuilder.init().withIncludeBackgroundSessions(inMetrics: true)
        Flurry.startSession("XK6QMKQTN6KVGWF4Y63X", with: builder)

        AdManager.shared.initAds()


        // delegate method, invoked when a notification is received
        func didReceive(_ message: FlurryMessage) {
            print("didReceiveMessage = \(message.description)")
            // additional logic here
        }
        
        // delegate method when a notification action is performed
        func didReceiveAction(withIdentifier identifier: String?, message: FlurryMessage) {
            print("didReceiveAction \(identifier ?? "no identifier"), Message = \(message.description)");
            // additional logic here, ex: deeplink. See Flurry Push Sample App for example
        }
        
        if isFlurryActive {
            Flurry.startSession("XK6QMKQTN6KVGWF4Y63X")
        }
        
        UIApplication.shared.statusBarStyle = .default
        
        AnalyticsHelper.updateSessionStartTimeIfNeeded(Date())

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .all
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (url.absoluteString.hasPrefix("fb")) {
            return handleOpenFbURL(url, app: app, options: options)
        }
        
        return true
    }
    
    
    // MARK: - Custom handlers
    
    fileprivate func handleOpenFbURL(_ url: URL, app: UIApplication, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let fbAppDelegate = ApplicationDelegate.shared
        let sourceApp = options[.sourceApplication] as! String
        let annotation = options[.annotation]
        
        return fbAppDelegate.application(app, open: url, sourceApplication: sourceApp, annotation: annotation)
    }
}

