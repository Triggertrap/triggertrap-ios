//
//  AppDelegate.swift
//  TriggertrapSLR
//
//  Created by Ross Gibson on 01/06/2015.
//  Copyright (c) 2015 Triggertrap Limited. All rights reserved.
//

import UIKit
import CoreSpotlight


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    fileprivate func generateStringsFromPlists() { 
        
        GenerateStringsFileFromPlist("Modes", plistType: .array)
        GenerateStringsFileFromPlist("distanceUnits", plistType: .dictionary)
        GenerateStringsFileFromPlist("speedUnits", plistType: .dictionary)
        GenerateStringsFileFromPlist("pulseLengths", plistType: .dictionary)
        GenerateStringsFileFromPlist("Options", plistType: .array)
    }
    
    fileprivate func indexActivities() {

        CSSearchableIndex.default().deleteAllSearchableItems(completionHandler: nil)
        
        let items = UserActivityManager.sharedInstance.activities.map { a in
            return
                CSSearchableItem(uniqueIdentifier: a.title, domainIdentifier: "Activities", attributeSet: a.searchableAttributeSet())
        }
        
        CSSearchableIndex.default().indexSearchableItems(items, completionHandler: { (error) -> Void in
            
            if error == nil {
                print("Indexed activity items: \(items.count)")
            } else {
                print("Error: \(String(describing: error))")
            }
        })
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Index all activities that can be searched using spotlight
        indexActivities()
        
//        generateStringsFromPlists()
        
        // Set the navigation bar appearance
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont.triggertrap_metric_regular(21.0), NSAttributedString.Key.foregroundColor: UIColor.triggertrap_fillColor(1.0)]
        
        UINavigationBar.appearance().barTintColor = UIColor.triggertrap_primaryColor()
        
        // Set the window background colour so that we don't see a black flicker when rotating
        window?.backgroundColor = UIColor.triggertrap_fillColor(1.0)

        DongleObserver.sharedInstance.dongleConnectedToPhone()
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
            
        // Check that user activity title is not the same as the current view controller as otherwise iOS will try to allocate a view controller which is being deallocated and crash the app
        if let identifier = userActivity.title, identifier != UserDefaults.standard.object(forKey: ConstDefaultLastSelectedMode) as? String {
            
            // Get the destination view controller from the identifier
            if let rootViewController = self.window?.rootViewController as? MainNavigationViewController, let sidebarViewController = rootViewController.viewControllers.first as? SidebarTableViewController, let storyboardName = StoryboardNameForViewControllerIdentifier(identifier) {
                    
                // Save the identifer to the user defaults for the last selected mode
                UserDefaults.standard.set(identifier, forKey: ConstDefaultLastSelectedMode)
                UserDefaults.standard.synchronize()
                
                let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
                
                let viewController = storyboard.instantiateViewController(withIdentifier: identifier)
                
                // Push the mode to be visible
                CachedPushNoAnimationStoryboardSegue(identifier: identifier, source: sidebarViewController, destination: viewController).perform()
            }
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        DongleObserver.sharedInstance.endSession()
    }
    
    func application(_ application: UIApplication, handleWatchKitExtensionRequest userInfo: [AnyHashable: Any]?, reply: @escaping ([AnyHashable: Any]?) -> Void) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: constWatchDidTrigger), object: nil)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if UserDefaults.standard.bool(forKey: constUserAcquired) == false {
            UserDefaults.standard.set(true, forKey: constUserAcquired)
            UserDefaults.standard.synchronize()
        }
        
        DongleObserver.sharedInstance.startSession()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        CachedPushNoAnimationStoryboardSegue.drainCache()
    }
    
    // MARK: - Onboarding
    
    func presentTutorial(_ vc: UIViewController) {
        let onboardingStoryboard = UIStoryboard(name: constStoryboardIdentifierOnboarding, bundle: Bundle.main)
        
        var viewControllerIdentifier: String?
        
        if (UserDefaults.standard.object(forKey: constSplashScreenIdentifier) != nil) {
            viewControllerIdentifier = constMobileKitIdentifier
        } else {
            viewControllerIdentifier = constSplashScreenIdentifier
            UserDefaults.standard.set(true, forKey: constSplashScreenIdentifier)
            UserDefaults.standard.synchronize()
        }
        
        // Make sure that the identifier is not nil (in case it gets changed by mistake)
        if let viewControllerIdentifier = viewControllerIdentifier {
            
            let viewController = onboardingStoryboard.instantiateViewController(withIdentifier: viewControllerIdentifier)
            let navController = onboardingStoryboard.instantiateInitialViewController() as! UINavigationController
            
            navController.viewControllers = [viewController]
            
            navController.modalPresentationStyle = UIModalPresentationStyle.formSheet
            
            //allows the onboarding process to controll it's own status bar
            navController.modalPresentationCapturesStatusBarAppearance = true
            viewController.modalPresentationCapturesStatusBarAppearance = true
            
            
            vc.present(navController, animated: true, completion: nil)
        } else {
            print("Warning: View Controller Identifier is nil. Cannot show onboarding")
        }
    }
    
    func presentCableSelector(_ vc: UIViewController) {
        
        let storyboard = UIStoryboard(name: constStoryboardIdentifierCableSelector, bundle: Bundle.main)
        
        let viewController = storyboard.instantiateInitialViewController()!
        
        viewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        vc.present(viewController, animated: true, completion: nil)
    }

}

