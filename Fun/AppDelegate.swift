//
//  AppDelegate.swift
//  Fun
//
//  Created by David Newman on 2/4/15.
//  Copyright (c) 2015 Assembly. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        application.statusBarHidden = true
        var navAppearance = UINavigationBar.appearance()
        navAppearance.translucent = false
        navAppearance.barTintColor = UIColor(red:0.19, green:0.17, blue:0.16, alpha:1.0)
        
        let cacheSizeMemory = 50*1024*1024; // 50 MB
        let cacheSizeDisk = 300*1024*1024; // 300 MB
        let sharedCache = NSURLCache(memoryCapacity: cacheSizeMemory, diskCapacity: cacheSizeDisk, diskPath: nil)
        NSURLCache.setSharedURLCache(sharedCache)
      
        // Set AudioSessionCategory
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient, error: nil)
      
        Fabric.with([Crashlytics()])
        
        var plist = NSBundle.mainBundle().pathForResource("configuration", ofType: "plist")
        var config = NSDictionary(contentsOfFile: plist!)!

        Flurry.startSession("937KPSK9TXHBHGTNFRZZ")

        // Google Analytics
        GAI.sharedInstance().dispatchInterval = 10
        GAI.sharedInstance().trackerWithTrackingId(config["GOOGLE_ANALYTICS_ID"] as NSString)
        GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory("ui_action", action: "app_launched", label:"launch", value:nil).build())

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
      FBAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
  
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
      return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
    }

    override class func initialize() -> Void {
        iRate.sharedInstance().onlyPromptIfLatestVersion = true
        //make sure the user likes the app. He needs to use it a certain amount of days and times.
        iRate.sharedInstance().usesUntilPrompt = 3
        iRate.sharedInstance().daysUntilPrompt = 2

        //iRate.sharedInstance().previewMode = true
    }
}

