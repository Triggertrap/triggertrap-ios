//
//  AppDelegate.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 01/06/2015.
//  Copyright (c) 2015 Triggertrap Limited. All rights reserved.
//

import UIKit
import CoreSpotlight
//import Fabric
//import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private func generateStringsFromPlists() { 
        
        GenerateStringsFileFromPlist("Modes", plistType: .Array)
        GenerateStringsFileFromPlist("distanceUnits", plistType: .Dictionary)
        GenerateStringsFileFromPlist("speedUnits", plistType: .Dictionary)
        GenerateStringsFileFromPlist("pulseLengths", plistType: .Dictionary)
        GenerateStringsFileFromPlist("Options", plistType: .Array)
    }
    
    private func indexActivities() {

        if #available(iOS 9.0, *) {
            CSSearchableIndex.defaultSearchableIndex().deleteAllSearchableItemsWithCompletionHandler(nil)
            
            let items = UserActivityManager.sharedInstance.activities.map { a in
                return
                    CSSearchableItem(uniqueIdentifier: a.title, domainIdentifier: "Activities", attributeSet: a.searchableAttributeSet())
            }
            
            CSSearchableIndex.defaultSearchableIndex().indexSearchableItems(items, completionHandler: { (error) -> Void in
                
                if error == nil {
                    print("Indexed activity items: \(items.count)")
                } else {
                    print("Error: \(error)")
                }
            })
        }
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
//        Fabric.with([Crashlytics.self])

        // Index all activities that can be searched using spotlight
        indexActivities()
        
//        generateStringsFromPlists()
        
        // Set the navigation bar appearance
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.triggertrap_metric_regular(21.0), NSForegroundColorAttributeName: UIColor.triggertrap_fillColor(1.0)]
        
        UINavigationBar.appearance().barTintColor = UIColor.triggertrap_primaryColor()
        
        // Set the window background colour so that we don't see a black flicker when rotating
        window?.backgroundColor = UIColor.triggertrap_fillColor(1.0)
        
        // Show the status bar
        UIApplication.sharedApplication().statusBarHidden = false
        
        switch AppTheme() {
        case .Normal:
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        case .Night:
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
        }
        
        DongleObserver.sharedInstance.dongleConnectedToPhone()
        PebbleManager.sharedInstance.setupPebbleWatch()
        
        return true
    }
    
    @available(iOS 8.0, *)
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        if #available(iOS 9.0, *) {
            
            // Check that user activity title is not the same as the current view controller as otherwise iOS will try to allocate a view controller which is being deallocated and crash the app
            if let identifier = userActivity.title where identifier != NSUserDefaults.standardUserDefaults().objectForKey(ConstDefaultLastSelectedMode) as? String {
                
                // Get the destination view controller from the identifier
                if let rootViewController = self.window?.rootViewController as? MainNavigationViewController, let sidebarViewController = rootViewController.viewControllers.first as? SidebarTableViewController, let storyboardName = StoryboardNameForViewControllerIdentifier(identifier) {
                        
                    // Save the identifer to the user defaults for the last selected mode
                    NSUserDefaults.standardUserDefaults().setObject(identifier, forKey: ConstDefaultLastSelectedMode)
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    let storyboard = UIStoryboard(name: storyboardName, bundle: NSBundle.mainBundle())
                    
                    let viewController = storyboard.instantiateViewControllerWithIdentifier(identifier)
                    
                    // Push the mode to be visible
                    CachedPushNoAnimationStoryboardSegue(identifier: identifier, source: sidebarViewController, destination: viewController).perform()
                }
            }
            
            return true
        }
        
        return false
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        MixpanelManager.sharedInstance.endSession()
        DongleObserver.sharedInstance.endSession()
    }
    
    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: ([NSObject : AnyObject]?) -> Void) {
        NSNotificationCenter.defaultCenter().postNotificationName(constWatchDidTrigger, object: nil)
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
        
        MixpanelManager.sharedInstance.startSession()
        
        if NSUserDefaults.standardUserDefaults().boolForKey(constUserAcquired) == false {
            MixpanelManager.sharedInstance.trackEvent(constUserAcquired)
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: constUserAcquired)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        DongleObserver.sharedInstance.startSession()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        CachedPushNoAnimationStoryboardSegue.drainCache()
    }
    
    // MARK: - Onboarding
    
    func presentTutorial(vc: UIViewController) {
        let onboardingStoryboard = UIStoryboard(name: constStoryboardIdentifierOnboarding, bundle: NSBundle.mainBundle())
        
        var viewControllerIdentifier: String?
        
        if (NSUserDefaults.standardUserDefaults().objectForKey(constSplashScreenIdentifier) != nil) {
            viewControllerIdentifier = constMobileKitIdentifier
        } else {
            viewControllerIdentifier = constSplashScreenIdentifier
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: constSplashScreenIdentifier)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        // Make sure that the identifier is not nil (in case it gets changed by mistake)
        if let viewControllerIdentifier = viewControllerIdentifier {
            
            let viewController = onboardingStoryboard.instantiateViewControllerWithIdentifier(viewControllerIdentifier)
            let navController = onboardingStoryboard.instantiateInitialViewController() as! UINavigationController
            
            navController.viewControllers = [viewController]
            
            navController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            vc.presentViewController(navController, animated: true, completion: nil)
        } else {
            print("Warning: View Controller Identifier is nil. Cannot show onboarding")
        }
    }
    
    func presentCableSelector(vc: UIViewController) {
        
        let storyboard = UIStoryboard(name: constStoryboardIdentifierCableSelector, bundle: NSBundle.mainBundle())
        
        let viewController = storyboard.instantiateInitialViewController()!
        
        viewController.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        vc.presentViewController(viewController, animated: true, completion: nil)
    }
    
    func presentInspiration(vc: UIViewController) {
        let storyboard = UIStoryboard(name: constStoryboardIdentifierInspiration, bundle: NSBundle.mainBundle())
        
        let viewController = storyboard.instantiateInitialViewController()!
        
        viewController.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        vc.presentViewController(viewController, animated: true, completion: nil)
    }
}

